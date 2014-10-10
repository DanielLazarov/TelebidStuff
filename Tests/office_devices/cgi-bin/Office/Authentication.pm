#!/usr/bin/perl 
package Office::Authentication;

use strict;
use warnings;

use Crypt::PBKDF2;
use Digest::SHA;
use DBI;
use Data::Dumper;

our $dbName = "office_devices";
our $host = "localhost";
our $user = "pg_user";
our $pw = "564564";



sub logIn($$)
{
    my ($dbh,$params) = @_;
    my $fbLogIn = 0;
    my $hash = '';
    my $cmd = '';
    my $sth ='';

    my $sha = Digest::SHA->new('sha512');

    if(defined $$params{'id'} && $$params{'id'})
    {
        $fbLogIn = 1;
        $cmd = 'SELECT * from users where fb_id = ?';
        $sth = $dbh->prepare($cmd);
        $sth->execute($$params{'id'});
    }
    else
    {
        $cmd = 'SELECT * from users where username = ?';
        $sth = $dbh->prepare($cmd);
        $sth->execute($$params{'username'});
    }

    my $row = $sth->fetchrow_hashref();
    if($fbLogIn)
    {
        open LOGIN, ">> /home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin/loginAccess.log";
        print LOGIN "[ " . localtime . " FB-Login ] FROM " . $ENV{REMOTE_ADDR} . " fb_id:" . $$params{'id'} . " name:" . $$params{'first_name'} . " " . $$params{'last_name'} . "\n";
        if($sth->rows)
        {
            if($$row{'activated'})
            {
                print LOGIN "Status: Successful Access\n";
                close LOGIN;
                return 1;
            }
            else
            {
                print LOGIN "Status: Successful Not Activated\n";
                close LOGIN;
                return 2;
            }
        }
        else
        {
            $sha->add($$params{'id'},$$params{'id'}); 
            $cmd = "INSERT INTO users(username,password,email,fb_id, fb_first_name, fb_last_name, fb_email) VALUES(?,?,?,?,?,?,?)";
            $sth = $dbh->prepare($cmd);
            $sth->execute($$params{'id'}, $sha->hexdigest, $$params{'email'}, $$params{'id'}, $$params{'first_name'}, $$params{'last_name'}, $$params{'email'});

            print LOGIN "Status: Successful Newly Created\n";
            close LOGIN;
            return 3;
        }
    }
    else
    {
        open LOGIN, ">> /home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin/loginAccess.log";
        print LOGIN "[ " . localtime . " ] FROM " . $ENV{REMOTE_ADDR} . " username:"  . $$params{'username'} . "\n";
        
        $sha->add($$params{'password'},$$params{'username'}); 
        
        if ($sha->hexdigest eq $$row{'password'}) 
        {
            if($$row{'activated'})
            {
                print LOGIN "Status: Successful Access\n";
                close LOGIN;
                return 1;
            }
            else
            {
                print LOGIN "Status: Successful Not Activated\n";
                close LOGIN;
                return 2;
            }
        }
        else 
        {
            print LOGIN "Status: Failed Wrong Info\n";
            close LOGIN;
            return 0;
        }

    }
}

sub SignUp($$)
{
    my($dbh, $params) = @_;

    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10000,
    );

    my $hash = $pbkdf2->generate($$params{'password'},$$params{'username'});
    my $cmd="INSERT INTO users(username,password,email) VALEUS (?,?,?)";
    my $sth=$dbh->prepare($cmd);
    $sth->execute($$params{'username'}, $hash, $$params{'email'});

    return 3;
}

sub fbLogInOrRegister
{

}


sub CheckStatus
{
    my $dbh = DBI->connect(
       "DBI:Pg:dbname=$dbName; host=$host",
       $user, 
       $pw,
       { 
           RaiseError => 1,
           AutoCommit => 0, 
           PrintError => 0, 
           HandleError => \&dieOnDBIError,     
       }
    );

    my $cmd = "SELECT * FROM sessions JOIN users ON sessions.user_id = users.id WHERE sessions.expires > now() AND user.id = ? AND session_id = ?";
    my $sth = $dbh->prepare($cmd);
    $sth->execute(cookie('c_user'), cookie('CGISESSID'));

    if($sth->rows)
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
