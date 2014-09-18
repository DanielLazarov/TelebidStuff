use strict;
use warnings;


open FILE, "myfile.as" or die "Couldn't open file: $!"; 
my $string = '';
while (<FILE>){
	my $line = $_;
	if(($line =~ /top/ || $line =~ /paytab/) && $line !~ /\/\/\//) {
	 $string .= $_;
	}
}
close FILE;

open(OUT, ">out.as") || die "Couldn't open file: $!";
print OUT $string;
close OUT;

#local $/ = undef;
#open FILE, "myfile.as" or die "Couldn't open file: $!";
#binmode FILE;
#my $string = <FILE>;
#close FILE;



