use warnings;
use strict;


input();

sub input {

	my $info;
	my $first;
	my $second;

	my @arr;
	my @splitInfo;
	my @splitFirst;
	my @splitSecond;

	my $k;
	my $l;
	my $r;
	my $i1;
	my $j1;
	my $i2;
	my $j2;
	
	while(1) {

		chomp ($info = <STDIN>);
		@splitInfo = split(/ +/, $info);		
		$k = $splitInfo[0];
		$l = $splitInfo[1];
		$r = $splitInfo[2];

		if($k !~ /\D/ &&  $l !~ /\D/ && $r !~ /\D/) {
			if($k > 0 && $l >= $k && $l <= 1000 && $r > 0 && $r <= 100 ) {
				chomp ($first = <STDIN>);
				@splitFirst = split(/ +/, $first);
				$i1 = $splitFirst[0];
				$j1 = $splitFirst[1];

				if($i1 !~ /\D/ && $j1 !~ /\D/) {
					if($i1 <= $k && $i1 > 0 && $j1 <= $l && $j1 > 0) {

						chomp ($second = <STDIN>);

						if($second) {
							@splitSecond = split(/ +/, $second);
							$i2 = $splitSecond[0];
							$j2 = $splitSecond[1];
							if($i2 !~ /\D/ && $j2 !~ /\D/) {
								if($i2 <= $k && $i2 > 0 && $j2 <= $l && $j2 > 0) {
									@arr = arrayPopulation($k, $l, $i1, $j1, $i2, $j2);	
									last;
								}
								else { 
									print "Wrong input on line 3, Enter all inputs again!\n";
								}
							}
							else { 
								print "Wrong input on line 3, Enter all inputs again!\n";
							}
						}
						else {
							@arr = arrayPopulation($k, $l, $i1, $j1);
							last;  
						}
					}
					else { 
						print "Wrong input on line 2, Enter all inputs again!\n";
					}
				}
				else { 
					print "Wrong input on line 2, Enter all inputs again!\n";
				}					
			}
			else { 
				print "Wrong input on line 1, Enter all inputs again!\n";
			}	
		}
		else { 
			print "Wrong input on line 1, Enter all inputs again!\n";
		}	
	}

	my $start_run = time();

	calc(\@arr, $k, $l, $r);

	my $end_run = time();
	my $run_time = $end_run - $start_run;
	print "Job took $run_time seconds\n";
	
}

sub calc() {
	my ($ref, $n, $m, $r) = @_;
	my $html = "<html><head><title>qgodki</title></head><body><table style = \"width:500px; height:500px\">";
	
	my @arr = @{$ref};
	my $currentDay = 1;
	
	for(my $days = 0; $days < $r; $days++) {
		for(my $i = 0; $i < $n; $i++) {

			for(my $j = 0; $j < $m; $j++) {
				if($arr[$i]->[$j] == $currentDay) {
					if($i+1 <$n && $arr[$i+1]->[$j] == 0) {
						$arr[$i+1]->[$j] = $currentDay + 1;
					}
					if($i-1 >=0 && $arr[$i-1]->[$j] == 0) {
						$arr[$i-1]->[$j] = $currentDay + 1;
					}
					if($j+1 <$m && $arr[$i]->[$j+1] == 0) {
						$arr[$i]->[$j+1] = $currentDay + 1;
					}
					if($j-1 >=0 && $arr[$i]->[$j-1] == 0) {
						$arr[$i]->[$j-1] = $currentDay + 1;
					}
				}

			}
		}
		$currentDay++;		
	}
	my $goodCounter = 0;
	for(my $i = 0; $i < $n; $i++) {
		for(my $j = 0; $j < $m; $j++) {
			if($arr[$i]->[$j] == 0) {
				$goodCounter++;
			}
		}		
	}
	print "$goodCounter \n";
	for(my $i = 0; $i < $n; $i++) {
		$html.="<tr>";
		for(my $j = 0; $j < $m; $j++) {
			if($arr[$i]->[$j]==0) {
				$html .= "<td style = \"background-color:rgb(189,61,196);\">$arr[$i]->[$j]</td>";
			}
			else {
			 $html .= "<td style = \"background-color:rgb(". ($arr[$i]->[$j]*10).",".($arr[$i]->[$j]*10).",".($arr[$i]->[$j]*10).");\">$arr[$i]->[$j]</td>";
			}
		}
		$html.="</tr>";	
	}
	$html.="</body></html>";
	open(my $fh, ">", "output.html")
    or die "cannot open > output.txt: $!";
	print $fh $html;
	close($fh);	
}

sub arrayPopulation(){
	my($n, $m, $i1, $j1, $i2, $j2) = @_;
	my @arr;

	for(my $i = 0; $i < $n; $i++) {
		my @arr1;

		for(my $j = 0; $j < $m; $j++) {
			if(($i+1 == ($n+1)-$i1 && $j+1 == $j1) || ($i2 && $j2 && $i+1 == ($n+1) - $i2 && $j+1 == $j2)) {
				$arr1[$j] = 1;			
			}
			else {
				$arr1[$j] = 0;	
			}
		}

		$arr[$i] = \@arr1;		
	}
	return @arr;
}




