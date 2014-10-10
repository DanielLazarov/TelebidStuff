use warnings;
use strict;


my @arr = ("aaa", "aaa", "aba", "baa");

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

if(isSorted(\@arr))
{
    print "sorted";
}
else
{
    print "NOQ"; 
}
