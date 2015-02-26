#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;

my $symbols = {
    first   => "a",
    a       => "b",
    b       => "c",
    c       => "d",
    d       => "e",
    e       => "f",
    f       => "g",
    g       => "h",
    h       => "i",
    i       => "j",
    j       => "k",
    k       => "l",
    l       => "m",
    m       => "n",
    n       => "o",
    o       => "p",
    p       => "q",
    q       => "r",
    r       => "s",
    s       => "t",
    t       => "u",
    u       => "v",
    v       => "w",
    w       => "x",
    x       => "y",
    y       => "z",
    z       => undef
};

sub sortThem($$)
{
    my($arr_ref, $symbols) = @_;

    my @arr = @{$arr_ref};
    my $last_index = $#arr;

    for(my $word_index = 0; $word_index < $last_index; $word_index++)
    {
        my $position = 0;
        while(1)
        {
            if(!substr($arr[$word_index], $position, 1) || !substr($arr[$word_index + 1], $position, 1))
            {
                last;
            }
            elsif(substr($arr[$word_index], $position, 1) ne substr($arr[$word_index + 1], $position, 1))
            {
                moveBefore({move =>substr($arr[$word_index], $position, 1) , before => substr($arr[$word_index + 1], $position, 1), symbols => $symbols});
                last;
            }
            else
            {
                $position++;
            }
        }
    }
}

sub areSorted($$)
{
    my ($arr_ref, $symbols) = @_;

    my @arr = @{$arr_ref};
    my @alph = ( "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z");
    my @coded;
    my $current_symbol = "first";
    while(1)
    {
        if(defined $$symbols{$current_symbol})
        {
            push(@coded, $$symbols{$current_symbol});
            $current_symbol = $$symbols{$current_symbol};
        }
        else
        {
            last;
        }
    }

    my $coded_hash;
    for(my $i = 0; $i < 26; $i++)
    {
        $$coded_hash{$coded[$i]} = $alph[$i];
    }
    
    foreach my $word (@arr)
    {
        my $length = length($word);
        for(my $i = 0; $i < $length; $i++)
        {
            substr($word,$i,1) = $$coded_hash{substr($word,$i,1)};
        }
    }
    
    my $word_count = scalar @arr;
    for(my $i = 0; $i < $word_count - 1; $i++)
    {
        if($arr[$i] gt $arr[$i+1])
        {
            return 0;
        }
    }
    
    return \@coded;
}

sub input()
{
    chomp(my $n = <STDIN>);
    my @arr;

    for (my $var = 0; $var < $n; $var++) {
        chomp (my $val = <STDIN>);
        print "value: $val \n"; 
        push @arr, $val;   
    }
    return \@arr;
}

sub moveBefore($)
{
    my ($args) = @_;

    my $symbols = $$args{symbols};
    my $move = $$args{move};
    my $before = $$args{before};
    
    foreach my $key (keys %{$symbols})
    { 
        if(defined $$symbols{$key})
        {
            if($$symbols{$key} eq $move)
            {
                $$symbols{$key} = $$symbols{$move};
            }
            if($$symbols{$key} eq $before)
            {
                $$symbols{$key} = $move;
            }
        }
    }

    $$symbols{$move} = $before;
}

my @arr = @{input()};
#my @arr = ("pn", "mp", "mn", "nm", "np");

sortThem(\@arr, $symbols);
my $result = areSorted(\@arr, $symbols);

if($result)
{
    print "Yes\n";
    print Dumper $result;
}
else
{
    print "NO\n";
}

