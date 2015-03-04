use warnings;
use strict;

use Data::Dumper;
use Config;


#print Dumper \%Config;
my $fh;


open $fh, ">", "test_file.bin";
my $count = 0;
while(1)
{
    my $type =  2;
    print $fh pack("c", $type);
    my $column_name = "column_name_1";
    print $fh $column_name; 
    print $fh "\0\1";
    $count++;
    if($count == 2)
    {
        last;
    }
}
print $fh pack("c", 1);
print $fh "\0\1test table";

print $fh "\0\1";

print $fh pack("c", 2);
print $fh 123;
close $fh;

open $fh , "<", "test_file.bin";

my $counter2 = 0;

while(1)
{
    my $buffer = "";

    read($fh, $buffer, 1);
    print "type: " . unpack("c", $buffer) . "\n";

    {   
        local $/ = "\0\1";
        my $t1 = <$fh>;
        print "table name: " , ord($t1) == 0 ?  "null" : $t1 , "\n";
    }
    $counter2++;
    if($counter2 == 4)
    {
        last;
    }
}
close $fh;
