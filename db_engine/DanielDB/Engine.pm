package DanielDB::Engine;

use strict;

use bytes;

use Config;
use Data::Dumper;

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

    print $fh pack("I", 0);
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

    read($fh, $buffer, $Config{intsize});
    my $row_count = unpack("I", $buffer);

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

    return \@col_arr, $row_count;
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

    return $result;
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
    
    my ($arr_ref, $row_count) = ReadTableMeta($fh);

    my @columns_arr = @{$arr_ref};
    my @colnames;
    my @result;

    foreach my $column(@columns_arr) #get Colnames
    {
        push @colnames, $$column{name};
    }
    push @result, \@colnames;

    while(!eof($fh))
    {
        my @row;

        my $row_flags = ReadRowMeta($fh);
        my $is_valid = 1;#TODO conditions!+
        foreach my $column(@columns_arr)
        {
            my $val = $$column{read}->($fh);
            #TODO do the checking
            if(!$is_valid)
            {
                last;
            }
            push @row, $val;
        }
        if($is_valid && !$$row_flags{deleted})
        {
            push @result, \@row;
        }
    }
    return \@result;
}

sub Insert($$$)#TODO insert_hash may be arr_ref
{
    my ($self, $table_name, $insert_hash) = @_;

    my $fh;
    if(!-f $$self{db_dir}. "/$table_name")
    {
        die "Not Existing Table";
    }
    open($fh, "+<" . $$self{db_dir} . "/$table_name") or die $!;

    my ($arr_ref, $row_count) = ReadTableMeta($fh);
   
    seek($fh, 0, 0);
    print $fh pack("I", $row_count + 1);
    seek($fh, 0, 2);
    my @columns_arr = @{$arr_ref};

    my $col_count = scalar @columns_arr;

    WriteRowMeta($fh);

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
    my $fhw;

    if(!-f $$self{db_dir} . "/$table_name")
    {
        die "Not Existing Table";
    }
    open($fh, "<", $$self{db_dir} . "/$table_name") or die $!; 
    open($fhw, ">>", $$self{db_dir} . "/$table_name") or die $!;
    
    my ($arr_ref, $row_count) = ReadTableMeta($fh);

    my @columns_arr = @{$arr_ref};
    my @colnames;
    foreach my $column(@columns_arr)
    {
        push @colnames, $$column{name};
    }

    my $row_counter = 0;    
    while($row_counter < $row_count)
    { 
        $row_counter++;
        local $| = 1; 
        my @row;
        my $is_valid = 1;

        my $row_beginning_pos = tell($fh);

        my $row_flags = ReadRowMeta($fh);
        #TODO skip deleted rows
        foreach my $column(@columns_arr)
        {
            my $val = $$column{read}->($fh);
            #TODO do the checking
            if(!$is_valid)
            {
                last;
            }
            push @row, $val;
        }

        my $next_row_position = tell($fh);
        seek($fh, $next_row_position - $row_beginning_pos, 1);
        

        if($is_valid)
        {
            my $cols_count = scalar(@columns_arr);
            my $update_row;

            for(my $i = 0; $i < $cols_count; $i++)
            {
                $$update_row{$columns_arr[$i]{name}} = exists ($$update_hash{$columns_arr[$i]{name}}) ?  $$update_hash{$columns_arr[$i]{name}} : $row[$i]; #TODO chec    
            }

            my $next_row_position = tell($fh);

            # seek($fh, $row_beginning_pos, 0);
            WriteRowMeta($fh, {deleted => 1});#updated row meta
            # seek($fh, 0, 2);          

            WriteRowMeta($fhw);#new row meta
            foreach my $column(@columns_arr)
            {
                $$column{write}->($fhw, $$update_row{$$column{name}});
            }   
            seek($fh, $next_row_position, 0);
        }
    }

    close($fh);
    close($fhw);
}

sub Delete($$)
{
    my($self, $table_name) = @_;            
}

sub ReadInt($)
{
    my ($fh) = @_;
    my $buffer = "";

    #info byte variables1
    my $is_null = 0;
   
    read($fh, $buffer, 1);
    my $flags = unpack("C", $buffer);
    if($flags & (1<<7))
    {
        $is_null = 1;
    }
    #7 more bits for meta info.

    read($fh, $buffer, $Config{intsize});
    return $is_null, unpack("i", $buffer);
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

    if($flags & (1<<7))
    {
        $is_null = 1;
    }

    read($fh, $buffer, $Config{intsize});
    my $str_length = unpack("I", $buffer);

    read($fh, $buffer, $str_length);

    return $is_null, $buffer;
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
