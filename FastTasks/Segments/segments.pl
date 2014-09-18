use warnings;
use strict;
my $n;
my $a;
my $b;
my $c;
while(1) {
	chomp(my $input = <STDIN>);
	my @inputSplited = split(" ", $input);
	$n = $inputSplited[0];
	$a = $inputSplited[1];
	$b = $inputSplited[2];
	$c = $inputSplited[3];

	if($n <= 0 || $a <= 0 || $b <= 0 || $c <= 0 || $n >= 100000 || $a >= 100000 || $b>= 100000 || $c>= 100000) {
		print"Wrong Input!\n";	
	}
	elsif($n =~ /\D/ || $a =~ /\D/ || $b =~ /\D/ ||$c =~ /\D/) {
		print"Wrong Input!\n";
	}
	else {
		
		my @arr = ();
		my $total = $n;
		my $count = 0;
		my @arrStarts = ();
		if($a == $c || $b == $c) {
			print "0\n";
		}
		for(my $i = 0; $i <= $n; $i++) {
			$arr[$i] = 0;
		}
		for(my $i = 0; $i <= $n; $i++) {
			if($i % $a == 0){
				$arr[$i] = 1;
			}

			if($i % $b == 0) {
				$arr[$n-$i] = 1;
			}		

		}
		for(my $i = 0; $i <= $n - $c; $i++) {
			if($arr[$i] == 1) {
				#for(my $j = $i; $j <=$i+$c; $j++) {
				#	if($arr[$j] == 1) {		
				#		$count = $j-$i;
				#		$i = $j-1;
				#		last;
				#	}
				if($arr[$i + $c] == 1) {
					$total-=$c;
					push(@arrStarts, $i);				
				}
			}
		}
		print "$total \n";
		#for(my $i = 0; $i <= $n; $i++) {
		#	#print "$arr[$i] ";
		#}
		my $current = 0;
		my $html = "<html><head><title>Segments</title></head><body><table style = \"width:800px; height:4px; border: 1px solid black; border-spacing: 0px;\" ><tr>";
		for(my $i = 0; $i < $n; $i++) {
			if($current<=$#arrStarts) {
				if($arrStarts[$current] == $i) {
					for(my $j = 0; $j<=$c; $j++) {
						if($arr[$i+$j]==1) {
							$html .= "<td style = \"background-color:rgb(255,0,0); text-align:center; padding : 0; \">&#8226;</td>";
						}
						else {
							$html .= "<td style = \"background-color:rgb(255,0,0); text-align:center; padding : 0; \">-</td>";
						}
					}
					
					#print "$current \n";
					$current++;
					$i+=$c-1;
				}
				else {
					if($arr[$i]==1) {
							$html .= "<td style = \"background-color:rgb(224,232,193); text-align:center; padding : 0; \">&#8226;</td>";
					}
					else {
						$html .= "<td style = \"background-color:rgb(224,232,193); text-align:center; padding : 0; \">-</td>";
					}			
			}
				
			}
			else {
				if($arr[$i]==1) {
							$html .= "<td style = \"background-color:rgb(224,232,193); text-align:center; padding : 0; \">&#8226;</td>";
					}
					else {
						$html .= "<td style = \"background-color:rgb(224,232,193); text-align:center; padding : 0; \">-</td>";
					}		
			}
		}
		$html.="</tr></table></body></html>";
		open(my $fh, ">", "outputSegments.html")
    	or die "cannot open > output.txt: $!";
		print $fh $html;
		close($fh);
		last;
		
	}
}
