use warnings;
use strict;




chomp(my $first = <>);
my @first = split(' ', $first);
our $n = $first[0];
our $m = $first[1];
my $maxlength = 0;

sub searchPath
{
    my ($start, $target, $arrayRef,$min,$max, $visitedRef, $st) = @_;
    my @array = @{$arrayRef};
    my @vis = @{$visitedRef};
    my $true = 0;
    if($array[$start][$target])
    {
        my @arr = @{$array[$start][$target]};
        for (my $var = 0; $var <= $#arr; $var++) 
        {
            if($arr[$var] >= $min && $arr[$var] <= $max)
            {
                if($min == 3 && $max == 7 && $st == 0)
                {
                    # print "FOUND! start: $st  Current: $start  Target: $target  Value: " . $arr[$var] . "\n";
                }
                $true = 1;
            }  
        } 
    }
    if($true)
    {
        return 1;
    }
    else
    {
        for (my $i = 0; $i < $m; $i++) {
            if($array[$start][$i] && !$vis[$start][$i])
            {
                my @arr = @{$array[$start][$i]};
                for (my $var = 0; $var <= $#arr; $var++) {
                    if($min == 3 && $max == 7 && $st == 0 && $i!= $st)
                    {
                        print "Possible Current: $start  Target: $target Next: $i  Value: " . $arr[$var] . "\n";
                    }
                    if($arr[$var] >= $min && $arr[$var] <= $max && $i!= $st)
                    {
                        $vis[$start][$i] = 1;
                        return searchPath($i, $target, \@array, $min, $max, \@vis, $st);
                    }
                    elsif($min == 3 && $max == 7 && $st == 0 && $i!= $st)
                    {
                         print "Missed   current: ".$start . "  target: " . $target . " next: " . $i . "  path: ". $arr[$var] , " min:$min max:$max\n";
                    } 
                }
            }
        }
    }
}

my @main;


for (my $i = 0; $i < $m; $i++) {
    chomp(my $line = <>);
    my @line = split(' ', $line);
    my $t1 = $line[0];
    my $t2 = $line[1];
    my $si = $line[2];
    if($si > $maxlength)
    {
        $maxlength = $si;
    }
    if($main[$t1-1][$t2-1])
    {
        my @arr = @{$main[$t1-1][$t2-1]};
        push(@arr, $si);
        $main[$t1-1][$t2-1] =  \@arr;
        $main[$t2-1][$t1-1] =  \@arr;
    }
    else
    {
        my @arr;
        push (@arr, $si);
        $main[$t1-1][$t2-1] =  \@arr;
        $main[$t2-1][$t1-1] =  \@arr;
    }
}
$| = 1;
my $optMin = $maxlength;
my $optMax = 1;
my $minDif = $maxlength;
for (my $max = 1; $max <= $maxlength; $max++) {
    for (my $min = 1; $min <= $max; $min++) {
        my $valid = 1;
        for (my $i = 0; $i < $n; $i++) {
            for (my $j = $i+1; $j < $n; $j++) {
                if($i!=$j)
                {
                    my @visited;
                    if(!searchPath($i,$j,\@main, $min, $max, \@visited, $i))
                    {
                        
                        if($min == 3 && $max == 7){
                             print "impossible for $i $j $min $max\n";
                        }
                        $valid = 0;
                    }
                }
            }
        }
        if($valid && $max-$min <= $minDif)
        {
            if($min < $optMin)
            {
                $optMin = $min;
                $optMax = $max;
            }
        }
    }
}
# for (my $i = 0; $i < $m; $i++) {
#     for (my $j = 0; $j < $m; $j++) {
#         print $i , ", " , $j , "--------------\n";
#         if($main[$i][$j])
#         {
#             my @arr = @{$main[$i][$j]};
#             for (my $e = 0; $e <= $#arr; $e++) {
#                 print $arr[$e] , "\n";
#             }
#         }
#     }
# }

print $optMin , " ", $optMax , "\n";
