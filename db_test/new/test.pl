use warnings;
use strict;

use Time::HiRes qw(usleep);
use Try::Tiny;
use DBI;



my $succeded_count = 0;
my $all_count = 0;

sub transaction($$$$){
    my ($no_of_threads, $sleep_microsec, $test_until, $isolation_level) = @_;
   
    my $dbh;
    
    while(1)
    {
        my $time = time;
        if($time >= $test_until)
        {
            last;
        }
        $all_count++;
        try
        {
            $dbh = DBI->connect("DBI:Pg:dbname=paralel_transaction_test;host=localhost", "transact_tester", "123", {PrintError => 1, RaiseError => 1, AutoCommit => 1}) or die $DBI::errstr;
            
            my $update_id = int(rand($no_of_threads)) + 1; 
            $dbh->do("BEGIN TRANSACTION ISOLATION LEVEL $isolation_level");
            my $sth = $dbh->prepare(q{
                SELECT * FROM foo where id = ?
            });
            $sth->execute($update_id);
            usleep($sleep_microsec);

            $sth = $dbh->prepare(q{
                UPDATE foo SET name = name || ? WHERE id = ?
            });
            $sth->execute(int(rand(9)) + 1, $update_id);
            usleep($sleep_microsec);

            $sth = $dbh->prepare(q{
                SELECT * FROM foo where id = ?
            });
            $sth->execute($update_id);
            usleep($sleep_microsec);
            $dbh->do("COMMIT");
            $succeded_count++;
        }
        catch
        {
	   {print($DBI::errstr);}
        }
    }
}

my $error_str = "Incorrect Input.
            Usage:
            perl test.pl <isolation_level> <wait_betwean_queries_milisec> <test_time_seconds> <proc_number> <total_no_of_processes>

            Isolation levels:
                -s - SERIALIZABLE
                -r - REPEATABLE READ
                -c - READ COMMITED\n";

if(!defined $ARGV[0] || !defined $ARGV[1] || !defined $ARGV[2] || !defined $ARGV[3])
{
    die $error_str;
}

my $isolation_selected = $ARGV[0];
my $sleep_microsec = $ARGV[1] * 1000;#in microseconds
my $test_untill = time() + $ARGV[2];#in seconds
my $proc_number = $ARGV[3];
my $total_no_of_processes = $ARGV[4];

my $isolation_level;

if($isolation_selected eq "-s")
{
    $isolation_level = "SERIALIZABLE";
}
elsif($isolation_selected eq "-r")
{
    $isolation_level = "REPEATABLE READ";
}
elsif($isolation_selected eq "-r")
{
    $isolation_level = "READ COMMITED";
}
else
{
    die $error_str;
}

transaction($total_no_of_processes, $sleep_microsec, $test_untill, $isolation_level);

my $fh;
open($fh, ">", $proc_number);
print $fh $succeded_count . "\n" . $all_count;
close $fh;


