#!/usr/bin/perl

use strict;
use warnings;

chomp(my $n = <STDIN>);


my $x = $n*$n;
my $y = $n*$n;

my @arr;
my @elements;
my $different = 1;
my $finished = 0;

for (my $i = 0; $i < $y; $i++) 
{
    chomp(my $line = <STDIN>);
    my @linearr = split(' ', $line );
    for (my $j = 0; $j < $x; $j++) 
    {
        if($linearr[$j])
        {
            $different = 1;
            for (my $var = 0; $var <= $#elements; $var++) 
            {
                if($linearr[$j] eq $elements[$var])
                {
                    $different = 0;
                }
            }   
            if($different)
            {
                push(@elements, $linearr[$j]);
            }
        }
        $arr[$i][$j] = $linearr[$j];
    }
}

while(!$finished)
{
    $finished = 1;
    for (my $i = 0; $i < $y; $i++) 
    {
        for (my $j = 0; $j < $x; $j++) 
        {
            if(!$arr[$i][$j])
            {
                $finished = 0;
            }
        }
    }

    for (my $i = 0; $i < $y; $i++) 
    {
        for (my $j = 0; $j < $x; $j++) 
        {
            if(!$arr[$i][$j])
            {
                check($i,$j);
            }
        }
    }
    print "-SO FAR- \n";
 
        for (my $iy = 0; $iy < $y; $iy++) 
    {
        for (my $jx = 0; $jx < $x; $jx++) 
        {
            print $arr[$iy][$jx];
            print " ";
        }
        print "\n";
    }
}

print "--- Solution --- \n\n";
    for (my $iy = 0; $iy < $y; $iy++) 
    {
        for (my $jx = 0; $jx < $x; $jx++) 
        {
            print $arr[$iy][$jx];
            print " ";
        }
        print "\n";
    }

sub check
{
    my($i, $j) = @_;
    my $toinsert;
    my $currentCount = 0;
    my $possibleCount = $y;

    for (my $element = 0; $element <= $#elements; $element++) {
        my $currentElement = $elements[$element];
        my $possibleColumnCount = 0;
        my $possibleRowCount = 0;
        my $possibleSquareCount = 0;

        if(possible($i,$j, $currentElement))
        {
            $toinsert = $currentElement;


            for (my $inner = 0; $inner < $y; $inner++) 
            {
                if(!$arr[$i][$inner])
                {
                    if(possible($i,$inner, $currentElement))
                    {
                        $possibleRowCount++;
                    }
                }

                if(!$arr[$inner][$j])
                {
                    if(possible($inner,$j, $currentElement))
                    {
                        $possibleColumnCount++;
                    } 
                }
            }
            #inner squere
            my $xindex = int($j/$n)*$n;
            my $yindex = int($i/$n)*$n;
            for (my $inneri = $yindex; $inneri < $yindex+$n; $inneri++) 
            {
                for (my $innerj = $xindex; $innerj < $xindex+$n; $innerj++) 
                {
                    if(!$arr[$inneri][$innerj])
                    {
                        if(possible($inneri,$innerj, $currentElement))
                        {
                            $possibleSquareCount++;
                        } 
                    }
                }
            }
            if($possibleRowCount == 1 || $possibleColumnCount == 1 || $possibleSquareCount == 1)
            {
                print "------Element $toinsert ------------\n";
                print "posrowcount: $possibleRowCount\n";
                print "poscolcount: $possibleColumnCount\n";
                print "possibleSquareCount: $possibleSquareCount\n";
                print "INSERTED at $i , $j\n\n\n";
                $arr[$i][$j] = $toinsert;
                last;
            }
        }
        else
        {
            $possibleCount--;
        }
    }
    print "Possible Count at $i , $j is $possibleCount\n";
     if($possibleCount == 1)
     {
         $arr[$i][$j] = $toinsert;
     }
}



sub possible 
{
    my($i, $j, $currentElement) = @_;
    for (my $inner = 0; $inner < $y; $inner++) 
    {
        if($arr[$i][$inner])
        {
            if($arr[$i][$inner] eq $currentElement)
            {
                return 0;
            }
        }

        if($arr[$inner][$j])
        {
            if($arr[$inner][$j] eq $currentElement)
            {
                return 0;
            } 
        }
    }
    #inner squere
    my $xindex = int($j/$n)*$n;
    my $yindex = int($i/$n)*$n;
    for (my $inneri = $yindex; $inneri < $yindex+$n; $inneri++) 
    {
        for (my $innerj = $xindex; $innerj < $xindex+$n; $innerj++) 
        {
            if($arr[$inneri][$innerj])
            {
                if($arr[$inneri][$innerj] eq $currentElement)
                {
                    return 0;
                }
            }
        }
    }
    return 1;
}

