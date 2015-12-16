use warnings;
use strict;

use Getopt::Long;
use Data::Dumper;

=pod
    Requires to be run as root.
    Options:
        --testdir=str
            in which dir to place the test file, used by fio for IO operations.The file will NOT be removed afterwards. The size of the file is 2x Total available RAM.
        --io-limit=i
            how many % of the total test file to use for tests. Default 5%.
        --block-size=i
            block size for read operations.  
=cut
my $params = {
    testdir => undef,
    io_limit => 5,
    total_ram => undef,
    block_size => undef,
};

GetOptions(
    "testdir=s"         => \$$params{testdir},
    "io-limit=i"        => \$$params{io_limit},
    "block-size=i"      => \$$params{block_size}         
) or die("Error in command line args\n");

if(!defined $$params{block_size}){die("use --block-size=str\n");}
if(!defined $$params{testdir}){die("use --testdir=str\n");}
if($$params{io_limit} <= 0 || $$params{io_limit} > 100){die("io-limit should be positive number betwean 0 and 100");}

#Get total available RAM
$$params{total_ram} = `cat /proc/meminfo | grep 'MemTotal:' | grep -Po '\\d*'`;
chomp($$params{total_ram});


print "Total memory: $$params{total_ram}\n";
print "Block size used: $$params{block_size}\n";

#seq read
`echo 3 > /proc/sys/vm/drop_caches`;
my $fio_result = `fio --minimal --name=psql_test --directory=$$params{testdir} --rw=read --size=@{[$$params{total_ram} * 2000]} --io_limit=@{[($$params{total_ram} * 2000) * ($$params{io_limit} / 100)]} --bs=$$params{block_size}`; #will test for only 5% of the size by default. Testing more would be more accurate but ain't nobody got time for that.
chomp($fio_result);
my @fio_values = split(/;/, $fio_result);

my $seq_kbps = $fio_values[6];
print "Read Kb/s: $seq_kbps\n";

#rand read
`echo 3 > /proc/sys/vm/drop_caches`;
$fio_result = `fio --minimal --name=psql_test --directory=$$params{testdir} --rw=randread --size=@{[$$params{total_ram} * 2000]} --io_limit=@{[($$params{total_ram} * 2000) * ($$params{io_limit} / 100)]} --bs=$$params{block_size}`;
chomp($fio_result);
@fio_values = split(/;/, $fio_result);

my $rand_kbps = $fio_values[6];
print "Random read Kb/s: $rand_kbps\n\n";

print "seq_page_cost: 1\n";
#IN PSQL default seq/rand speed is assumed to be 1/50. The cost factors are 1/4 which means 12.5 lower than file system results, because of possible caching.
print "random_page_cost: @{[($seq_kbps / $rand_kbps) / 12.5]}\n";


#Effective cache size
`echo 3 > /proc/sys/vm/drop_caches`;
my $effective_cache_size = `cat /proc/meminfo | grep 'MemFree:' | grep -Po '\\d*'`;
chomp($effective_cache_size);
$effective_cache_size = int($effective_cache_size / 1000); #in MB
$effective_cache_size .= "MB";
print "effective_cache_size: $effective_cache_size\n";

