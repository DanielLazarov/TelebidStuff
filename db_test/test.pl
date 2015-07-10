use warnings;
use strict;

use threads;
use threads::shared;

use Time::HiRes qw(usleep);
use Try::Tiny;
use DBI;



my $succeded_count = 0;
my $all_count = 0;
share($succeded_count);
share($all_count);

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
            $dbh = DBI->connect("DBI:Pg:dbname=paralel_transaction_test;host=localhost", "transact_tester", "123", {PrintError => 0, RaiseError => 1, AutoCommit => 1}) or die $DBI::errstr;
            
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
        }
    }
}

my $error_str = "Incorrect Input.
            Usage:
            perl test.pl <isolation_level> <no_of_paralel_transactions> <wait_betwean_queries_milisec> <test_time_seconds>

            Isolation levels:
                -s - SERIALIZABLE
                -r - REPEATABLE READ
                -c - READ COMMITED\n";

if(!defined $ARGV[0] || !defined $ARGV[1] || !defined $ARGV[2] || !defined $ARGV[3])
{
    die $error_str;
}

my $isolation_selected = $ARGV[0];
my $no_of_threads = $ARGV[1];
my $sleep_microsec = $ARGV[2] * 1000;#in microseconds
my $test_untill = time() + $ARGV[3];#in seconds

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

my @arr;
for(my $i = 0; $i < $no_of_threads; $i++)
{
    push @arr, threads->create(\&transaction, $no_of_threads, $sleep_microsec, $test_untill, $isolation_level);
}

foreach my $thread (@arr)
{
    $thread->join();
}

print "succeeded: $succeded_count/$all_count(" . sprintf("%.2f", $succeded_count/$all_count*100) . "%) \n";


