use warnings;
use strict;




chomp(my $first = <>);
my @first = split(' ', $first);
our $n = $first[0];
our $m = $first[1];
my $maxlength = 0;

sub searchPath
{
    my ($start, $target, $arrayRef,$min,$max, $visitedRef, $st, $inner) = @_;
    my @array = @{$arrayRef};
    my @vis = @{$visitedRef};
    $vis[$start] = 1;

    for (my $i = 0; $i < $n; $i++) {
        if($i == $target && $array[$start][$i] && !$vis[$i])
        {
            my @arr = @{$array[$start][$i]};
            for (my $var = 0; $var <= $#arr; $var++) 
            {
                if($arr[$var] >= $min && $arr[$var] <= $max)
                {
                    return 1;
                }
            }
        }
    }
    my $found = 0;
    for (my $i = 0; $i < $n; $i++) {
        if($array[$start][$i] && !$vis[$i])
        {
            my @arr = @{$array[$start][$i]};
            for (my $var = 0; $var <= $#arr; $var++) 
            {
                if($arr[$var] >= $min && $arr[$var] <= $max)
                {
                    if(searchPath($i, $target, \@array, $min, $max, \@vis, $st, 1))
                    {
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
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
            for (my $j = $i; $j < $n; $j++) {
                if($i!=$j)
                {
                    my @visited;
                    if(!searchPath($i,$j,\@main, $min, $max, \@visited, $i, 0))
                    {
                        $valid = 0;
                    }
                }
            }
        }
        if($valid && $max-$min < $minDif)
        {
            $optMin = $min;
            $optMax = $max;
            $minDif = $max - $min;
        }
        elsif($valid && $max-$min == $minDif)
        {
            if($min < $optMin)
            {
                $optMin = $min;
                $optMax = $max;
            }
        }
    }
}

print "Min: " . $optMin . "  Max: ". $optMax , "\n";
