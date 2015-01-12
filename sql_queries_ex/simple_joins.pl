use warnings;
use strict;

#TODO Create Aliases for the tables(now names are repeating when there are cycles).
my %test_data = (
        a => {
            cycles => 2,
            visited => 0,
            table_name => 'a',
            is_left => 0,
            foreign_keys => 
            [
                {
                    fkey_to => 'b',
                    fkey_null => 0,
                    fkey_inner_column => 'b_id',
                    fkey_outer_column => 'id'
                },
            ]
        },

        b => {
            cycles => 2,
            visited => 0,
            table_name => 'b',
            is_left => 0,
            foreign_keys => 
            [
                {
                    fkey_to => 'c',
                    fkey_null => 1,
                    fkey_inner_column => 'c_id',
                    fkey_outer_column => 'id'
                }
            ]
        },

        c => {
            cycles => 2,
            visited => 0,
            table_name => 'c',
            is_left => 0,
            foreign_keys => 
            [
                {
                    fkey_to => 'd',
                    fkey_null => 0,
                    fkey_inner_column => 'd_id',
                    fkey_outer_column => 'id'
                },
                {
                    fkey_to => 'a',
                    fkey_null => 0,
                    fkey_inner_column => 'a_id',
                    fkey_outer_column => 'id'
                },
                {
                    fkey_to => 'e',
                    fkey_null => 1,
                    fkey_inner_column => 'e_id',
                    fkey_outer_column => 'id'
                },
            ]
        },
         d => {
            cycles => 1,
            visited => 0,
            table_name => 'd',
            is_left => 0,
            foreign_keys => undef
        },

        e => {
            cycles => 1,
            visited => 0,
            table_name => 'd',
            is_left => 0,
            foreign_keys => undef
        },


    );

#Creates a SELECT * query with JOINS, following the direction of Joins, starting from the desired table.
sub makePath($$;$);
sub makePath($$;$)
{
    my ($tables, $current_table_name, $query) = @_;

    my $current_table = $$tables{$current_table_name};
    
    if(defined $query)#first time does not count.
    {
        $$current_table{visited}++;
    }
    
    # JOIN All the tables, that are connected to the first one with a NOT NULL foreign key before going further.
    if(!defined $query)
    {
        $query = "SELECT * FROM " . $$current_table{table_name} . "\n";
        if(defined $$current_table{foreign_keys})
        {
            for my $foreign_key (@{$$current_table{foreign_keys}})
            {
                if(!$$foreign_key{fkey_null})
                {
                
                    $query .=  " JOIN " . $$foreign_key{fkey_to} . 
                    " ON " . $$current_table{table_name} . "." . $$foreign_key{fkey_inner_column} . 
                    " = " . $$foreign_key{fkey_to} . "." . $$foreign_key{fkey_outer_column} . "\n";
                }
            }
        }

        $query = makePath($tables, $$current_table{table_name}, $query);
    }
    elsif(defined $$current_table{foreign_keys} )
    {
        for my $foreign_key (@{$$current_table{foreign_keys}})
        {
            #Check if the desired cycle count is reached 
            if($$tables{$$foreign_key{fkey_to}}{visited} < $$tables{$$foreign_key{fkey_to}}{cycles})
            {                                               
                if($$foreign_key{fkey_null} || (!$$foreign_key{fkey_null} && $$current_table{is_left}) )
                {
                    $query .=  " LEFT JOIN " . $$foreign_key{fkey_to} . 
                    " ON " . $$current_table{table_name} . "." . $$foreign_key{fkey_inner_column} . 
                    " = " . $$foreign_key{fkey_to} . "." . $$foreign_key{fkey_outer_column} . "\n";
                    $$tables{$$foreign_key{fkey_to}}{is_left} = 1;
                }
                else
                {
                    $query .=  " JOIN " . $$foreign_key{fkey_to} . 
                    " ON " . $$current_table{table_name} . "." . $$foreign_key{fkey_inner_column} . 
                    " = " . $$foreign_key{fkey_to} . "." . $$foreign_key{fkey_outer_column} . "\n";
                }
                $query = makePath($tables, $$foreign_key{fkey_to}, $query);
            }
        }
    }
    return $query;
}

#test.
my $result = makePath(\%test_data, 'a');
print $result;
