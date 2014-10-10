#!/usr/bin/perl
use warnings;
use strict;

my %map = (
    'a' => 'a',
    'b' => 'b',
    'c' => 'c',
    'd' => 'd',
    'e' => 'e',
    'f' => 'f',
    'g' => 'g',
    'h' => 'h',
    'i' => 'i',
    'j' => 'j',
    'k' => 'k',
    'l' => 'l',
    'm' => 'm',
    'n' => 'n',
    'o' => 'o',
    'p' => 'p',
    'q' => 'q',
    'r' => 'r',
    's' => 's',
    't' => 't',
    'u' => 'u',
    'v' => 'v',
    'w' => 'w',
    'x' => 'x',
    'y' => 'y',
    'z' => 'z',
    );

sub answer($;$)
{
    my ($check, $hashRef) = @_;

    if($check)
    {
        print "Yes\n";
        my @keyArr;
        foreach my $key (keys %{$hashRef})
        {
            push @keyArr, $key;
        }
        @keyArr = sort @keyArr;
        foreach (@keyArr)
        {
            print $map{$_};
        }
        print "\n";
    }
    else
    {
        print "No \n";
    }
}


sub isSorted($)
{
    my @arr = @{$_[0]};

    for (my $i = 0; $i< $#arr; $i++)
    {
        if($arr[$i] gt $arr[$i+1])
        {
            return 0;
        }
    }
    return 1;
}

sub input
{
    chomp(my $n = <STDIN>);
    my @arr;

    for (my $var = 0; $var < $n; $var++) {
        chomp (my $val = <STDIN>);
        push @arr, $val;   
    }
    return \@arr;
}
my $success = 0;
my @arr = @{input()};

foreach my $key (keys %map)
{
    foreach my $keyInner (keys %map)
    {
        my @currentArr = @arr;
        if($key ne $keyInner)
        {
            my $tmp = $map{$key};
            $map{$key} = $map{$keyInner};
            $map{$keyInner} = $tmp;
            for (my $i = 0; $i <= $#arr; $i++) 
            {
                for (my $j = 0; $j < length($currentArr[$i]); $j++) 
                {
                    substr($currentArr[$i],$j,1) = $map{substr $arr[$i] , $j, 1};
                }
            }

            if(isSorted(\@currentArr))
            {
                $success = 1;
                last;
            }
        }
    }
    if($success)
    {
        last;
    }
}

answer($success, \%map);