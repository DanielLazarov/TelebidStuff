use warnings;
use strict;
 use IPC::SysV qw(IPC_PRIVATE);
use Time::HiRes qw(usleep);
use Try::Tiny;
use DBI;





#share($succeded_count);
#share($all_count);
my $ipckey = IPC_PRIVATE;
my $ipckey1 = IPC_PRIVATE;
my $ipckey2 = IPC_PRIVATE;

my $idshm = shmget( $ipckey, 4, 0666 ) || die "\nCreation shared memory failed $! \n";
my $idshm1 = shmget( $ipckey, 4, 0666) || die "\nCreation shared memory failed $! \n";
my $idshm2 = shmget( $ipckey, 4, 0666) || die "\nCreation shared memory failed $! \n";

shmwrite($idshm, pack("i", 0), 0, 4);
shmwrite($idshm1, pack("i", 0), 0, 4);
shmwrite($idshm2, pack("i", 0), 0, 4);

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
        my $current_count;
        shmread( $idshm, $current_count, 0, 4 ) || warn "\n\n shmread $! \n";
        shmwrite($idshm, pack("i", unpack("i", $current_count) + 1), 0, 4) || warn "\n\n shmwrite $! \n";

#        $all_count++;
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
            my $succeded_count;
            shmread( $idshm1, $succeded_count, 0, 4 ) || warn "\n\n shmread $! \n";
            shmwrite($idshm1,  pack("i", unpack("i", $succeded_count) + 1), 0, 4) || warn "\n\n shmwrite $! \n";


        }
        catch
        {
            my $failed_count;
            shmread( $idshm2, $failed_count, 0, 4 ) || warn "\n\n shmread $! \n";
            shmwrite($idshm2,  pack("i", unpack("i", $failed_count) + 1), 0, 4) || warn "\n\n shmwrite $! \n";
   
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

for(my $i = 0; $i < $no_of_threads; $i++)
{
    my $pid;
    next if $pid = fork;    # Parent goes to next server.
    die "fork failed: $!" unless defined $pid;

    transaction($no_of_threads, $sleep_microsec, $test_untill, $isolation_level);
    # From here on, we're in the child.  Do whatever the
    # child has to do...  The server we want to deal
    # with is in $server.

    exit;  # Ends the child process.
}

# The following waits until all child processes have
# finished, before allowing the parent to die.

1 while (wait() != -1);

print "All done!\n";
        my $succeded_count_buff;
        my $succeded_count;
        
        my $failed_count_buff;
        my $failed_count;

        my $all_count_buff;
        my $all_count;
        
        shmread( $idshm, $all_count_buff, 0, 4 ) || warn "\n\n shmread $! \n"; 
        shmread( $idshm1, $succeded_count_buff, 0, 4 ) || warn "\n\n shmread $! \n";
        shmread( $idshm2, $failed_count_buff, 0, 4) || warn "\n\n shmread $! \n";

$succeded_count = unpack("i", $succeded_count_buff);
$all_count = unpack("i", $all_count_buff);
$failed_count = unpack("i", $failed_count_buff);

print "succeeded: $succeded_count/$all_count(" . sprintf("%.2f", $succeded_count/$all_count*100) . "%) \n";
print "failed: " . $failed_count . "\n";
