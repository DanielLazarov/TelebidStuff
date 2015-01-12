#!/usr/bin/perl 
package Office::Utilities;

sub ASSERT($)
{
    my ($statement) = @_;

    if(!$statement)
    {
        die "ASSERT FAILURE";
    }
}

sub TRACE($;$$)
{
    my($message, $value, $type)
}