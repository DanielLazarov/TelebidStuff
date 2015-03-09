package DanielDB::Engine;

use strict;

use bytes;

use Config;
use Data::Dumper;
use IO::File;

=pod
Daniel DB.
=cut

my $DDB_ROOT_DIR = "/var/daniel_db/";
my $DELIMITER = "\0\1";

our $type_map = {
    "int" => 1,
    "text" => 2
};

our $sub_map = {
    1 => {read => \&ReadInt, write => \&WriteInt},
    2 => {read => \&ReadString, write => \&WriteString}
};

sub connect($$)
{
	my ($class, $db) = @_;

    my $err_log;

    if(!defined $db)
    {
        return bless {}, $class;
    }
    elsif( -d "$DDB_ROOT_DIR" . $db)
    {
        return bless {db_dir => $DDB_ROOT_DIR . $db}, $class;   
    }
    else
    {
        die "Not existing database: $db\n";
    }
}

sub CreateDB($)
{
    my ($db_name) = @_;

    mkdir($DDB_ROOT_DIR . $db_name) or die $!;
}

sub CreateTable($$$)
{
    my ($self, $table_name, $columns) = @_;
    
    if(-f $$self{db_dir} . "/$table_name")
    {
        die "Table already exists";
    }

    my $fh;
    open($fh, ">" . $$self{db_dir} . "/$table_name") or die   $$self{db_dir} . "/$table_name" .$!;

    my @columns_arr = @{$columns};

    #print $fh pack("I", 0);
    print $fh pack("C", scalar @columns_arr); #column count

    foreach my $column(@columns_arr)
    {
        print $fh pack("C", $$type_map{$$column{type}});
        print $fh pack("C", length($$column{name}));
        print $fh $$column{name};
    }
    close($fh);
}

sub ReadTableMeta($)
{
    my ($fh) = @_;

    my @col_arr;
    
    seek $fh,0,0; #set fh at beginning

    my $buffer = "";

    #read($fh, $buffer, $Config{intsize});
    #my $row_count = unpack("I", $buffer);

    read($fh, $buffer, 1);
    my $col_count = unpack("C", $buffer);
    
    for(my $i = 0; $i < $col_count; $i++)
    {
        my $column;

        read($fh, $buffer, 1);
        $$column{type} = unpack("C", $buffer);
        $$column{read} = $$sub_map{$$column{type}}{read};
        $$column{write} = $$sub_map{$$column{type}}{write};
     
        read($fh, $buffer, 1);
        my $colname_length = unpack("C", $buffer); #in bytes
        read($fh, $buffer, $colname_length);
        $$column{name} = $buffer;

        push @col_arr, $column;
    }
    return $fh, \@col_arr;    #TODO remove row count.
}

sub ReadRow($$)
{
    my($fh, $arr_of_handlers_ref) = @_;

    my @arr_of_handlers = @{$arr_of_handlers_ref};

    my @row;
    foreach my $handler(@arr_of_handlers)
    {
        push @row, $handler->($fh);
    }

    return $fh, \@row;
}

sub WriteRow($$$)
{
    my($fh, $arr_of_handlers_ref, $arr_of_values_ref) = @_;

    my @arr_of_handlers = @{$arr_of_handlers_ref};
    my @arr_of_values = @{$arr_of_values_ref};

    my $length = scalar @arr_of_handlers;

    for(my $i = 0; $i < $length; $i++)
    {
        $arr_of_handlers[$i]->($fh, $arr_of_values[$i]);
    }
}

sub WriteRow1($$$)
{
    my($table_name, $arr_of_handlers_ref, $arr_of_values_ref) = @_;

    my $fh;
    open($fh, ">>", $table_name);

    my @arr_of_handlers = @{$arr_of_handlers_ref};
    my @arr_of_values = @{$arr_of_values_ref};

    my $length = scalar @arr_of_handlers;

    for(my $i = 0; $i < $length; $i++)
    {
        $arr_of_handlers[$i]->($fh, $arr_of_values[$i]);
    }

    close($fh);
}

sub Select($$;$)
{
    my ($self, $table_name, $select_hash) = @_;

    my $fh;

    if(!-f $$self{db_dir} . "/$table_name")
    {
        die "Not Existing Table";
    }
    open($fh, "<", $$self{db_dir} . "/$table_name") or die $!;
    
    seek($fh,0,2);
    my $last_pos = tell($fh);
    seek($fh,0,0);


    my ($fh, $arr_ref) = ReadTableMeta($fh);

    my @columns_arr = @{$arr_ref};
    my @colnames;
    my @handlers;
    my @result;

    foreach my $column(@columns_arr) #get Colnames
    {
        push @colnames, $$column{name};
        push @handlers, $$column{read};
    }
    push @result, \@colnames;

    while(tell($fh) < $last_pos)
    {
        my ($fh, $row_flags) = ReadRowMeta($fh);
        my ($fh, $row) = ReadRow($fh, \@handlers);

        my $is_valid = 1;#TODO conditions!+
    

        if($is_valid && !$$row_flags{deleted})
        {
            # push @result, $row;
        }
    }
    return \@result;
}

sub Insert($$$)#TODO insert_hash may be arr_ref(bulk)
{
    my ($self, $table_name, $insert_hash) = @_;

    my $fh;
    if(!-f $$self{db_dir}. "/$table_name")
    {
        die "Not Existing Table";
    }
    open($fh, "+<" . $$self{db_dir} . "/$table_name") or die $!;

    my $arr_ref;

    ($fh, $arr_ref) = ReadTableMeta($fh);
   
    my @columns_arr = @{$arr_ref};

    my $col_count = scalar @columns_arr;
    seek($fh, 0, 2);
    $fh = WriteRowMeta($fh);

    foreach my $column(@columns_arr)
    {
        $$column{write}->($fh, $$insert_hash{$$column{name}});
    }
    
    close($fh);
}


sub Update($$$)
{
    my ($self, $table_name, $update_hash) = @_;

    my $fh;

    if(!-f $$self{db_dir} . "/$table_name")
    {
        die "Not Existing Table";
    }
    open($fh, "+<", $$self{db_dir} . "/$table_name") or die $!; 
    
    seek($fh,0,2);
    my $last_pos = tell($fh);    
    seek($fh,0,0);
    
    my $arr_ref;
    ($fh, $arr_ref) = ReadTableMeta($fh);
    
    my @columns_arr = @{$arr_ref};
    my @handlers_read;
    my @handlers_write;

    foreach my $column(@columns_arr) #get Colnames
    {
        push @handlers_read, $$column{read};
        push @handlers_write, $$column{write}
    }

    while(tell($fh) < $last_pos)
    {
        my $beginning_row_pos = tell($fh);
        my ($fh, $row_flags) = ReadRowMeta($fh);
        my ($fh, $row_ref) = ReadRow($fh, \@handlers_read);

        my @row = @{$row_ref};
        my $is_valid = 1;#TODO conditions!+

        if($is_valid && !$$row_flags{deleted})
        {
            my $next_row_pos = tell($fh);
            seek($fh, $beginning_row_pos, 0);
            $fh = WriteRowMeta($fh, {deleted => 1});
            
            my $cols_count = scalar(@columns_arr);
            my $update_row;

            for(my $i = 0; $i < $cols_count; $i++)
            {
                $$update_row{$columns_arr[$i]{name}} = exists ($$update_hash{$columns_arr[$i]{name}}) ?  $$update_hash{$columns_arr[$i]{name}} : $row[$i];    
            }
            seek($fh, 0,2);        

            $fh = WriteRowMeta($fh);
            foreach my $column(@columns_arr)
            {
                $$column{write}->($fh, $$update_row{$$column{name}});
            }
            #$fh = WriteRow($fh, \@handlers_write, $update_row);

            seek($fh, $next_row_pos, 0);
        }
    }

    close($fh);
}

sub DeleteRecord($$;$)
{
    my($self, $table_name, $conditions_hash) = @_;     

    my $fh;
    my $arr_ref;

    open ($fh, "+<", $$self{db_dir} . "/" . $table_name);

    seek($fh,0,2);
    my $last_pos = tell($fh);
    print "Last pos: $last_pos";
    seek($fh,0,0);

    ($fh, $arr_ref) = ReadTableMeta($fh);
    
    my @columns_arr = @{$arr_ref};
    my @handlers;
    my @result;

    foreach my $column(@columns_arr) #get Colnames
    {
        push @handlers, $$column{read};
    }

    while(tell($fh) < $last_pos)
    {
        my $row_beginning = tell($fh);

        my $row_flags;
        my $row;
        ($fh, $row_flags) = ReadRowMeta($fh);
        ($fh, $row) = ReadRow($fh, \@handlers);

        my $is_valid = 1;#TODO conditions!+
    
        if($is_valid && !$$row_flags{deleted})
        {
            my $row_ending = tell($fh);
            seek($fh, $row_beginning, 0);
            $fh = WriteRowMeta($fh, {deleted => 1});
            seek($fh, $row_ending, 0);
        }
    }

    close($fh);
}

sub WriteRowMeta($;$)
{
    my($fh, $params) = @_;

    my $flags = 0;

    if(defined $$params{deleted} && $$params{deleted})
    {
        $flags += 128;
    }

    print $fh pack("C",$flags );

    return $fh;
}

sub ReadRowMeta($)
{
    my($fh) = @_;

    my $result= {
        deleted => 0
    };

    my $buffer;
    read($fh, $buffer, 1);  
    my $flags = unpack("C", $buffer);
    
    if($flags & (1<<7))
    {
        $$result{deleted} = 1;
    }

    return ($fh, $result);
}
sub ReadInt($)
{
    my ($fh) = @_;
    my $buffer = "";

    #info byte variables1
    my $is_null = 0;
   
    read($fh, $buffer, 1);
    my $flags = unpack("C", $buffer);

    read($fh, $buffer, $Config{intsize});

    if($flags & (1<<7))
    {
        return undef;
    }
    else
    {
        return unpack("i", $buffer);
    }
}

sub WriteInt($$)
{
    my ($fh, $value) = @_;

    my $flags = 0;

    if(!defined $value)
    {
        $flags += 128;
    }
    
    print $fh pack("C", $flags);
    print $fh pack("i", $value);
}

sub ReadString($)
{
    my ($fh) = @_;
    
    my $buffer ="";

    my $is_null = 0;
    
    read($fh, $buffer, 1);
    my $flags = unpack("C", $buffer);

    read($fh, $buffer, $Config{intsize});
    my $str_length = unpack("I", $buffer);
    read($fh, $buffer, $str_length);

    if($flags & (1<<7))
    {
        return undef;
    }
    else
    {
        return $buffer;
    }
}

sub WriteString($$)
{
    my ($fh, $value) = @_;
    
    my $flags = 0;
    if(!defined $value)
    {
        $flags += 128;
    }
    
    print $fh pack("C", $flags);
    print $fh pack("I", bytes::length($value));
    print $fh $value;
}
