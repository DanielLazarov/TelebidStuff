#!/usr/bin/perl

package Office::Responses;

use strict;
use warnings;


use CGI::Session;
use CGI qw/:standard/;

our $defaultLanguage = 'en';


sub MakeHeader($;$$$)
{
    my %HoF = (
        'already_in'            =>  \&AlreadyIn,
        'no_access'             =>  \&NoAccess,
        'login'                 =>  \&Login,
        'logout'                =>  \&LogOut,
        'language_switch'       =>  \&LanguageSwitch,
    );

    my ($choice, $params, $type, $charset) = @_;

    return header(
                -cookie=>$HoF{lc $choice}->($params),
                -type=> defined $type ? $type : 'application/json',
                -charset=> defined $charset ? $charset : 'utf-8'
            );  
}

sub AlreadyIn
{
    my @cookies;

    my $session = CGI::Session->load(cookie('CGISESSID')); 
    $session->expire('+30m');
    
    my $cookieSessionID = CGI::Cookie->new(
        -name=>'CGISESSID',
        -value=>$session->id,
        -expires => '+30m'
    );
    push @cookies, $cookieSessionID;

    my $cookieUsername = CGI::Cookie->new(
        -name=>'username',
        -value=>cookie('username'),
        -expires => '+30m'
    );
    push @cookies, $cookieUsername;

    my $cookieLanguage = CGI::Cookie->new(
        -name=>'language',
        -value=>cookie('language'),
        -expires => '+1M'
    );
    push @cookies, $cookieLanguage;

    return \@cookies;
}

sub NoAccess
{
    return '';
}

sub Login
{
    my($params) = @_;

    my $session = CGI::Session->new(); 
    $session->expire('+30m');

    my @cookies;

    my $cookieSessionID;
    my $cookieUsername;
    my $cookieLanguage;

    $cookieSessionID = CGI::Cookie->new(-name=>'CGISESSID', -value=>$session->id, -expires => '+30m');
    push @cookies, $cookieSessionID;

    if($$params{'params'}{'first_name'})
    {
        $cookieUsername = CGI::Cookie->new(-name=>'username', -value=>$$params{'params'}{'first_name'}, -expires => '+30m');
    }
    else
    {
        $cookieUsername = CGI::Cookie->new(-name=>'username', -value=>$$params{'params'}{'username'}, -expires => '+30m');
    }
    push @cookies, $cookieUsername;

    if(cookie('language'))
    {
        $cookieLanguage = CGI::Cookie->new(-name=>'language', -value=>cookie('language'), -expires => '+1M');
    }
    else
    {
        $cookieLanguage = CGI::Cookie->new(-name=>'language', -value=>$defaultLanguage, -expires => '+1M');  
    }
    push @cookies, $cookieLanguage;

    return \@cookies;
}

sub LogOut
{
    my @cookies;

    my $session = CGI::Session->load(cookie('CGISESSID'));

    my $cookieSessionID = CGI::Cookie->new(
        -name       => 'CGISESSID',
        -value      => '',
        -expires    =>  '-1d',
    );
    push @cookies, $cookieSessionID;

    my $cookieUsername = CGI::Cookie->new(
        -name       => 'username',
        -value      => '',
        -expires    =>  '-1d',
    );
    push @cookies, $cookieUsername;

    $session->delete();
    $session->flush();

    return \@cookies;
}

sub LanguageSwitch
{
    my ($params) = @_;
    my $cookieLanguage = CGI::Cookie->new(
        -name=>'language',
        -value=>$$params{'params'}{'language'},
        -expires => '+1M'
    );

    return $cookieLanguage;
}


sub BuildJSONrpc
{
    my ($json_rpc, $result, $id) = @_;
    my %response = (
            'jsonrpc'  => $json_rpc,
            'result'    => $result,
            'id'        => $id
        );
    return JSON->new->encode(\%response);
}