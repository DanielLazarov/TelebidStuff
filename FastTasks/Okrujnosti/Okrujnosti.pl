use warnings;
use strict;

use GD;
# create a new image (width, height)
my $img = newTrueColor GD::Image(4000, 4000);
my $range = 255;
my $n;
my $x;
my $y;
my $r;
    # allocate some colors
my $white = $img->colorAllocate(255,255,255);

    # make the background transparent and interlaced
    $img->transparent($white);
    $img->interlaced('true');

    # make sure we are writing to a binary stream

$| = 1;
    # for(my $i = 0; $i<10; $i++)
    # {
    #   open FILE, " > result.png";
    #   binmode FILE;
    #   my $r = rand(1000);
    #   my $x = rand(3000);
    #   my $y = rand(3000);
    #   print "x: ". $x . ", y: " . $y . ", r: " .$r . "\n";
       #  $img->arc($x,$y,$r,$r,0,360,$img->colorAllocate(rand($range),rand($range),rand($range)));

       #  # And fill it with red
       #  $img->fill($x,$y,$img->colorAllocate(rand($range),rand($range),rand($range)));
       #  print FILE $img->png;
       #  close FILE;
       #  sleep 5;
    # }

    # Convert the image to PNG and print it on standard output
while(1)
{
    print "Number of circles: \n";
    chomp($n = <>);
    if($n!~/^-?\d/)
    {
        print "Not a numeric input, try again. \n";
    }
    elsif($n < 2 || $n > 1000)
    {
        print "The number should be in range[2;1000]. \n";
    }
    else
    {
        last;
    }
}
my @circles;
my @graph;
my $mincount = $n;
for (my $var = 0; $var < $n; $var++) 
{
    for (my $var1 = 0; $var1 < $n; $var1++) 
    {
            $graph[$var][$var1] = 0;
    }
}
#Getting all circles input and populates the graph matrix
for(my $i = 0; $i < $n; $i++) 
{
    while(1)
    {
        chomp(my $input = <STDIN>);
        my @splited = split(/ /,$input);
        $x = $splited[0];
        $y = $splited[1];
        $r = $splited[2];
        if($x!~/^-?\d/ || $y!~/^-?\d/ || $r!~/^-?\d/)
        {
            print "Not a numeric input, try again. \n";
        }
        elsif($x <= -10000 || $x >= 10000 || $y <= -10000 || $y >= 10000 || $r <=0 || $y >= 10000)
        {
            print "The numbers should be in range x:(-10000;10000) y:(-10000;10000) r:(0;10000) . \n";
        }
        else
        {
            last;
        }
    }

    open FILE, " > result.png";
    binmode FILE;

    # $img->arc($x/10+2000, $y/10+2000, $r/5, $r/5, 0, 360, $img->colorAllocate(rand($range), rand($range), rand($range)));
    $img->filledEllipse($x/10+2000, $y/-10+2000, $r/5, $r/5, $img->colorAllocate(rand($range), rand($range), rand($range)));

    # And fill it with red
    # $img->fill($x/10+2000, $y/10+2000, $img->colorAllocate(rand($range), rand($range), rand($range)));
    print FILE $img->png;
    close FILE;

    #TODO Draw the Circle
    for (my $var = 0; $var < $i; $var++) 
    {
        if($x!=$circles[$var][0] || $y!=$circles[$var][1])
        {
            my $d = sqrt(($x-$circles[$var][0])**2 + ($y-$circles[$var][1])**2);
            if($d< $r + $circles[$var][2]) 
            {
                if($d < $r || $d < $circles[$var][2]) 
                {
                    if($r < $circles[$var][2]) 
                    {# $r is smaller
                        if($d+$r > $circles[$var][2])
                        {
                            #TODO Draw the line
                            $graph[$i][$var] = 1;
                            $graph[$var][$i] = 1;
                        }
                    }
                    else 
                    {
                        if($d + $circles[$var][2] > $r)
                        {# $circles[$var][2] is smaller or equal
                            #TODO Draw the line
                            $graph[$i][$var] = 1;
                            $graph[$var][$i] = 1;
                        }
                    }

                }
                else 
                {
                    #TODO Draw the line
                    $graph[$i][$var] = 1;
                    $graph[$var][$i] = 1;
                }
            }
        }
    }
    $circles[$i][0] = $x;
    $circles[$i][1] = $y;
    $circles[$i][2] = $r;
}

searchPath(0,0);
if($mincount < $n) 
{
    print "$mincount \n";
}
else 
{
    print "-1\n";
}
sub searchPath 
{
    my($i,$count) = @_;
    for(my $j = $i; $j < $n; $j++) 
    {
        if($graph[$i][$j]) 
        {
            if($j == $n-1) 
            {
                $count++;
                if($count < $mincount)
                {
                    $mincount = $count;
                }
            }
            else
            {
                searchPath($j,$count + 1);
            }   
        }
    }
}

#print current graph
for (my $var = 0; $var < $n; $var++) 
{
    for (my $var1 = 0; $var1 < $n; $var1++) 
    {
        print $graph[$var][$var1];
    }
    print "\n";
}

