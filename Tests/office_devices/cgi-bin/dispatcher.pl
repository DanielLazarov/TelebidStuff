#!/usr/bin/perl

use warnings;
use strict;
use lib '/home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin';

use Apache::DBI;
use DBI;
use JSON;
use Encode;
use Data::Dumper;
use Try::Tiny;
use CGI::Session;
use CGI qw/:standard/;

use Office::CustomDD;
use Office::FGenerator;
use Office::DBInteraction;
use Office::Authentication;
use Office::Responses;

our %HoF = (
    'custom_dropdown_fill'  =>  \&Office::CustomDD::customDropDown,
    'generate_form'         =>  \&Office::FGenerator::generateForm, 
    'insert_or_update'      =>  \&Office::DBInteraction::insertOrUpdateRecord,
    'delete_record'         =>  \&Office::DBInteraction::deleteRecord,
    'login'                 =>  \&Office::Authentication::logIn,
    'logout'                =>  \&LogOut,
    'signup'                =>  \&Office::Authentication::SignUp
);


#Dispatch();




sub Dispatch
{
    my $cgi = CGI->new;
    my $requestData = JSON->new->decode($cgi->param('json_rpc'));

    print $HoF{lc $$requestData{'method'}}->();
}















our $dbName = "office_devices";
our $host = "localhost";
our $user = "pg_user";
our $pw = "564564";

our $dbh;

our $session;
our $cookieUsername;
our $cookieLanguage;
our $cookieSessionID;
our $header;


our $cgi = CGI->new;
our $client = $cgi->remote_addr();

our $requestData = JSON->new->decode($cgi->param('json_rpc'));

if($$requestData{'method'} eq 'login' )
{
    processLogIn();
}
elsif($$requestData{'method'} eq 'logout' )
{
    LogOut();
}
elsif($$requestData{'method'} eq 'language_switch' )
{
    LanguageSwitch();
}
else
{
    if(cookie('CGISESSID'))
    {
        processDataLoggedIn();
    }
    else
    {
        my %result = ('message' => '<script>location.reload()</script>');

        print Office::Responses::MakeHeader('no_access');
        print BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
    }
}

sub dispatch
{
    my ($header, $dbh, $method, $params) = @_;
    print $header, BuildJSONrpc($$requestData{'jsonrpc'}, $HoF{lc $method}->($dbh,$params), $$requestData{'id'});
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

sub processDataLoggedIn 
{
    $header = Office::Responses::MakeHeader('already_in');

    try{
        $dbh = DBI->connect(
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
        if($cgi->param('data_type'))
        {
            dispatch($header,$dbh,$$requestData{'method'},$cgi);
        }
        else
        {
            dispatch($header,$dbh,$$requestData{'method'},$$requestData{'params'});
        }
        $dbh->commit;
        $dbh->disconnect;
    }
    catch
    {
        open FILE, "> /home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin/error.log";
        print FILE "[" . localtime . " from: " . $client . "]" , Dumper($_) , "\n";
        close FILE;

        if($$_{'code'})
        {
            handleDBIErrors($header, $$requestData{'jsonrpc'}, $$requestData{'id'}, $_);
        }
        else
        {
            my %result = (
                'status'    => 'sys_error',
                'code'      => -32002, #Server error
                'message'   => "errSomething went wrong.",
            );
            print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
        }

        if($dbh)
        {
            $dbh->rollback;
            $dbh->disconnect;
        }
        
    };
}

sub processLogIn{

    $header = Office::Responses::MakeHeader('no_access');

    try{
        $dbh = DBI->connect(
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

        my $auth = Office::Authentication::logIn($dbh,$$requestData{'params'});

        if($auth == 1)
        {

            my %result = ('message' => '<script>location.reload()</script>');


            $header = Office::Responses::MakeHeader('login', $requestData);

            print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
        }
        else
        {
            my %result;
            if($auth == 0)
            {
                %result = ('message' => '*Incorrect Username or Password');
            }
            elsif($auth == 2)
            {
                %result = ('message' => '*Your account will be activated soon.');
            }
            elsif($auth == 3)
            {
                %result = ('message' => '*Your account has been created! You will be gained access soon.');
            }
            else
            {
                %result = ('message' => '*Something went wrong with the authentication.');
            } 
            print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
        }
        $dbh->commit;
        $dbh->disconnect;
    }
    catch
    {
        open FILE, ">> /home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin/loginError.log";
        print FILE "[" . localtime . " from: " . $client . "]" , Dumper($_)  ,"\n";
        close FILE;

        if($dbh)
        {
            $dbh->rollback;
            $dbh->disconnect;
        }

        my %result = (
            'status'    => 'sys_error',
            'code'      => -32002, #Server error
            'message'   => "Something went wrong.",
        );
        print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
    };

}

sub dieOnDBIError
{
    my %hash = (
        'number'    => $dbh->err(),
        'code'      => $dbh->state(),
        'message'   => $dbh->errstr()
        );
    die \%hash;
}

sub handleDBIErrors
{
    my($header,$jsonrpc,$id, $errorHash) = @_;
    open FILE, ">> /home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin/errorDBI.log";
    print FILE "[" . localtime . " from: " . $client . "]" . $$errorHash{'message'} . "\n";
    close FILE;

    my %result;

    if($$errorHash{'code'} eq 23505)
    {
        %result = (
            'status'    => 'peer_error',
            'code'      => -32003, #Server error
            'message'   => "Error: Such record already exists.",
        );
    }
    elsif($$errorHash{'code'} eq 23503)
    {
        %result = (
            'status'    => 'peer_error',
            'code'      => -32003, #Server error
            'message'   => "Error: Involving non existant record",
        );
    }
    else
    {
        %result = (
            'status'    => 'peer_error',
            'code'      => -32003, #Server error
            'message'   => "An error occured while Inserting a new record",      
        );      
    }
    print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
}

sub LogOut
{
    my %result = ('message' => '<script>location.reload()</script>');

    $header = Office::Responses::MakeHeader('logout');
    print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
}

sub LanguageSwitch
{
    my %result = ('message' => '<script>location.reload()</script>');

    $header = Office::Responses::MakeHeader('language_switch', $requestData);
    print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
}