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

our %HoF = (
    'custom_dropdown_fill'  =>  \&Office::CustomDD::customDropDown,
    'generate_form'         =>  \&Office::FGenerator::generateForm, 
    'insert_or_update'      =>  \&Office::DBInteraction::insertOrUpdateRecord,
    'delete_record'         =>  \&Office::DBInteraction::deleteRecord,
    'login'                 =>  \&Office::Authentication::logIn,
);

our $dbName = "office_devices";
our $host = "localhost";
our $user = "pg_user";
our $pw = "564564";
our $defaultLanguage = 'en';

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
else
{
    if(cookie('CGISESSID'))
    {
        processDataLoggedIn();
    }
    else
    {
        $cookieLanguage = $cgi->cookie(-name=>'language', -value=>$defaultLanguage, -expires => '+1M');
        $header = $cgi->header(
                        -cookie=>$cookieLanguage,
                        -type=>'application/json',
                        -charset=>'utf-8'
                    );

        my %result = ('message' => '<script>window.location = "https://10.20.2.104:442"</script>');

        print $header;
        print BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
    }
}
# close ERRORLOG;

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
    $session = CGI::Session->load(cookie('CGISESSID')); 
    $session->expire('+30m');
    $cookieSessionID = CGI::Cookie->new(-name=>'CGISESSID', -value=>$session->id, -expires => '+30m');
    $cookieUsername = CGI::Cookie->new(-name=>'username', -value=>cookie('username'), -expires => '+30m');
    $cookieLanguage = CGI::Cookie->new(-name=>'language', -value=>cookie('language'), -expires => '+1M');

    $header = header(
                    -cookie=>[$cookieSessionID,$cookieUsername,$cookieLanguage],
                    -type=>'application/json',
                    -charset=>'utf-8'
                );

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
        #$$_{'code'}    -> Postgress error code!!!
        #$$_{'code'}    -> Some Number
        #$$_{'code'}    -> Official Error Message
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
                'message'   => "Something went wrong.",
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

        if(Office::Authentication::logIn($dbh,$$requestData{'params'}))
        {
            $session = CGI::Session->new(); 
            $session->expire('+30m');
            $cookieSessionID = CGI::Cookie->new(-name=>'CGISESSID', -value=>$session->id, -expires => '+30m');
            $cookieUsername = CGI::Cookie->new(-name=>'username', -value=>$$requestData{'params'}{'username'}, -expires => '+30m');
            if(cookie('language'))
            {
                $cookieLanguage = CGI::Cookie->new(-name=>'language', -value=>cookie('language'), -expires => '+1M');
            }
            else
            {
                $cookieLanguage = CGI::Cookie->new(-name=>'language', -value=>$defaultLanguage, -expires => '+1M');  
            }
            
            $header = header(
                    -cookie=>[$cookieSessionID,$cookieUsername,$cookieLanguage],
                    -type=>'application/json',
                    -charset=>'utf-8'
                );
            my %result = ('message' => '<script>window.location = "https://10.20.2.104:442"</script>');
            print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
        }
        else
        {
            $header = header(
                    -type=>'application/json',
                    -charset=>'utf-8'
                );

            my %result = ('message' => '*Incorrect Username or Password');
            print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
        }
        $dbh->commit;
        $dbh->disconnect;
    }
    catch
    {
        open FILE, ">> /home/daniel/Repositories/TelebidStuff/Tests/office_devices/cgi-bin/loginError.log";
        print FILE "[" . localtime . " from: " . $client . "]" , $_  ,"\n";
        close FILE;
        if($dbh)
        {
            $dbh->rollback;
            $dbh->disconnect;
        }

        # print ERRORLOG "[" . localtime . "]", $_, "\n";
        my %result = (
            'status'    => 'sys_error',
            'code'      => -32002, #Server error
            'message'   => "Something went wrong.",
        );
        print $header, BuildJSONrpc($$requestData{'jsonrpc'}, \%result, $$requestData{'id'});
    };

}

#handle DBI Errors.
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