#!/usr/bin/perl

use strict;
use warnings;

use CGI::Session;
use CGI qw/:standard/;
use HTML::Template;
use Try::Tiny;

our %HoF = (
    'notloggedin' =>  \&notLoggedInOutput,
    'loggedin'    =>  \&loggedInOutput,
    'error'       =>  \&errorOutput,
);

my $r = shift;
our $cgi = CGI->new($r);
my $logged = 1;

try{
    if($cgi->param('logout'))
    {
        if(cookie('CGISESSID'))
        {#Already Logged in.
            my $session = CGI::Session->load(cookie('CGISESSID'));
            $session->delete();
            $logged = 0;
        }
    }

    if(cookie('CGISESSID') && $logged)
    {#Already Logged in.
        out('loggedin');
    }

    else 
    {#NOT Logged in.
        out('notloggedin');
    }
}
catch
{
    out('error');
};

sub out
{
    my $cmd = $_[0];
    print $HoF{lc $cmd}->();
}

sub notLoggedInOutput
{
    my $string; 
    {
        local $/ = undef;
        open FILE, "/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/login.html" or die "Couldn't open file: $!";
         $string = <FILE>;
        close FILE;
    }

    #Expire the cookies
    my $cookie1 = CGI::Cookie->new(
        -name       => 'CGISESSID',
        -value      => '',
        -expires    =>  '-1d',
    );
    my $cookie2 = CGI::Cookie->new(
        -name       => 'username',
        -value      => '',
        -expires    =>  '-1d',
    );
    return $cgi->header(
                    -cookie=>[$cookie1,$cookie2],
                    -charset=>'utf-8'
                ),
            $string;
}

sub loggedInOutput
{
    my $session = CGI::Session->load(cookie('CGISESSID')); 
    
    $session->expire('+10m');
    my $cookie1 = CGI::Cookie->new(
        -name=>$session->name,
        -value=>$session->id,
        -expires =>  '+10m',
    );
    my $cookie2 = CGI::Cookie->new(
        -name=>'username',
        -value=>cookie('username'),
        -expires =>  '+10m',
    );
    my $cookie3 = CGI::Cookie->new(
        -name=>'language',
        -value=>cookie('language'),
    );

    my $template = HTML::Template->new(filename => '/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/index.tmpl') or die "Couldn't open file: $!";
    $template->param(USERNAME => cookie('username'));

    open(TRANSLATIONS, "< /home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/translations.txt") or die "Couldn't open file: $!";
    my $languageIndex = 0;
    my $header = 1;

    while(my $line = <TRANSLATIONS>)
    {
        chomp($line);
        my @args = split(',', $line);
        if($header)
        {
            for (my $i = 0; $i <= $#args; $i++) 
            {
                if($args[$i] eq cookie('language'))
                {
                    $languageIndex = $i;
                }
            }
            $header = 0;
        }
        #Translation exists
        if($args[$languageIndex])
        {
            $template->param($args[0] => $args[$languageIndex]);    
        }
        #Default(english) translation exists
        elsif($args[1])
        {
            $template->param($args[0] => $args[1]);
        }
        #no Translation avaidable
        else
        {
            $template->param($args[0] => $args[0]);
        }
    }
    close TRANSLATIONS;

    return $session->header(
        -cookie=>[$cookie1,$cookie2,$cookie3], 
        -charset=>'utf-8'
    ),
    $template->output;
}

sub errorOutput
{
    return $cgi->header(-charset=>'utf-8'), "<p>There was a problem loading the page, please try again later</p>";
}