use warnings;
use strict;

my $i = 1;
my $str = "";
if($ARGV[0]<=0||$ARGV[0]>=3200000) {
	print "Incorrect Input \n";
	exit;
}
while(1) {
	$str = $str . ($i*$i);
	if(length($str) >= 3200000) {
		last;
	} 
	$i++;
}

print substr($str, $ARGV[0] - 1, 1) . "\n";



	
