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

our $found = 0;

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
# my $success = 0;
my @arr = @{input()};
my @takenArr;
my @currentArr;


Permutate(0,25,\@takenArr,\@currentArr,\%map, \@arr);


if(!$found)
{
    print "No\n";
}

# foreach my $key (keys %map)
# {
#     foreach my $keyInner (keys %map)
#     {
#         my @currentArr = @arr;
#         if($key ne $keyInner)
#         {
#             my $tmp = $map{$key};
#             $map{$key} = $map{$keyInner};
#             $map{$keyInner} = $tmp;
#             for (my $i = 0; $i <= $#arr; $i++) 
#             {
#                 for (my $j = 0; $j < length($currentArr[$i]); $j++) 
#                 {
#                     substr($currentArr[$i],$j,1) = $map{substr $arr[$i] , $j, 1};
#                 }
#             }

#             if(isSorted(\@currentArr))
#             {
#                 $success = 1;
#                 last;
#             }
#         }
#     }
#     if($success)
#     {
#         last;
#     }
# }

# answer($success, \%map);

our $counter = 0;

sub Permutate
{
    my ($currentPosition,$last,$takenArrRef,$currentArrRef,$mapRef, $inputArrRef) = @_;
    my $sorted = "abcdefghijklmnopqrstuvwxyz";
    my $isLast = 0;
    my @taken = @{$takenArrRef};
    my @currentArr = @{$currentArrRef};
    my @inputArr = @{$inputArrRef};
    if(!$found)
    {
        if($currentPosition == $last)
    {
        $isLast = 1;
    }


    for (my $j = 0; $j <= $last; $j++) {
        if($currentPosition == 0)
        {
            print "currently on first position: " . substr $sorted, $j, 1;
            print "\n";
        }
        my $possible = 1;
        for (my $i = 0; $i <= $#taken; $i++) {
            if($taken[$i] eq substr($sorted,$j, 1))
            {
                $possible = 0;
            }
        }
        if($possible)
        {
            $currentArr[$currentPosition] = substr($sorted,$j, 1);
            push @taken, substr($sorted,$j, 1);
            if(!$isLast)
            {

                Permutate($currentPosition + 1, $last, \@taken, \@currentArr,$mapRef, $inputArrRef);
                splice @taken, $#taken, 1;            
            }
            else
            {
                for (my $i = 0; $i <= $#currentArr; $i++) {
                    $map{substr($sorted,$i,1)} = $currentArr[$i];
                }

                for (my $i = 0; $i <= $#inputArr; $i++) 
                {
                    for (my $j = 0; $j < length($inputArr[$i]); $j++) 
                    {
                        substr($inputArr[$i],$j,1) = $map{substr $arr[$i] , $j, 1};
                    }
                }

                if(isSorted(\@inputArr))
                {   
                    $found = 1;
                    print "Yes\n",  @currentArr , "\n";
                }
            }
        }
    }

    }

    
}