use warnings;
use strict;

use Time::HiRes qw(usleep);
use Try::Tiny;
use DBI;

use Parallel::ForkManager;


my $pm = Parallel::ForkManager->new(100);
our $counters = { all => 0, succeded => 0};
  
$pm -> run_on_finish (
    sub {
        my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference) = @_;
        
        $$counters{all} += $$data_structure_reference{all};
        $$counters{succeded} += $$data_structure_reference{succeded};
    }
);


sub transaction($$$$){
    my ($no_of_threads, $sleep_microsec, $test_until, $isolation_level) = @_;
   
    my $dbh;
    my $inner_counters = {all => 0, succeded => 0};    
    while(1)
    {
        my $time = time;
        if($time >= $test_until)
        {
            last;
        }
        
        $$inner_counters{all}++;
        
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

            $$inner_counters{succeded}++;
        }
        catch
        {
        } 
    }

    $pm->finish(0, $inner_counters);
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
elsif($isolation_selected eq "-rc")
{
    $isolation_level = "READ COMMITED";
}
else
{
    die $error_str;
}

print "Isolation: $isolation_level, paralel: $no_of_threads, sleep: $ARGV[2], Test time: $ARGV[3]  \n";

TRANSACTIONS:
for(my $i = 0; $i < $no_of_threads; $i++)
{
    $pm->start() and next TRANSACTIONS;
    transaction($no_of_threads, $sleep_microsec, $test_untill, $isolation_level);
}


$pm->wait_all_children;

my $succeded_count = $$counters{succeded};
my $all_count = $$counters{all};

print "succeeded: $succeded_count/$all_count(" . sprintf("%.2f", $succeded_count/$all_count*100) . "%) \n";
