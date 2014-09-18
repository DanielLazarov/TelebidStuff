#!/usr/bin/perl 
package Office::Authentication;

use strict;
use warnings;


use Crypt::PBKDF2;
use DBI;


sub logIn($$)
{
	my ($dbh,$params) = @_;

    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10000,
    );

    my $hash = $pbkdf2->generate($$params{'password'},$$params{'username'});

    my $cmd = 'SELECT password from users where username = ?';
    my $sth = $dbh->prepare($cmd);
    $sth->execute($$params{'username'});

    my $row = $sth->fetchrow_hashref();

    #validate the password
    if ($hash eq $row->{'password'}) 
    {
        return 1;
    }
    else 
    {
        return 0;
    }
}

1;
__END__
