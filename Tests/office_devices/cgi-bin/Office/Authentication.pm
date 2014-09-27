#!/usr/bin/perl 
package Office::Authentication;

use strict;
use warnings;

use Data::Dumper;
use Crypt::PBKDF2;
use DBI;


sub logIn($$)
{
	my ($dbh,$params) = @_;
    my $fbLogIn = 0;
    my $hash = '';
    my $cmd = '';
    my $sth ='';
    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10000,
    );

    if(defined $$params{'id'} && $$params{'id'})
    {
        $fbLogIn = 1;
        $cmd = 'SELECT * from users where fb_id = ?';
        $sth = $dbh->prepare($cmd);
        $sth->execute($$params{'id'});
    }
    else
    {
        $hash = $pbkdf2->generate($$params{'password'},$$params{'username'});
        $cmd = 'SELECT * from users where username = ?';
        $sth = $dbh->prepare($cmd);
        $sth->execute($$params{'username'});
    }

    my $row = $sth->fetchrow_hashref();
    if($fbLogIn)
    {
        if($sth->rows)
        {
            if($$row{'activated'})
            {
                return 1;
            }
            else
            {
                return 2;
            }
        }
        else
        {
            $hash = $pbkdf2->generate($$params{'id'},$$params{'id'});
            $cmd = "INSERT INTO users(username,password,fb_id, fb_first_name, fb_last_name, fb_email) VALUES(?,?,?,?,?)";
            $sth = $dbh->prepare($cmd);
            $sth->execute($$params{'id'}, $hash, $$params{'id'}, $$params{'first_name'}, $$params{'last_name'}, $$params{'email'});
            return 3;
        }
    }
    else
    {
        open LOGIN, "> /home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin/loginAccess.txt";
        print LOGIN Dumper($row);
        close LOGIN;
        if ($hash eq $$row{'password'}) 
        {
            if($$row{'activated'})
            {
                return 1;
            }
            else
            {
                return 2;
            }
        }
        else 
        {
            return 0;
        }
    }
}

1;
__END__
