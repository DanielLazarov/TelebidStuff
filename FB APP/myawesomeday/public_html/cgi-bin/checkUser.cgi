#!/usr/bin/perl -w
use CGI;
use strict;
use DBI;
use warnings;

print "Content-type: text/html\n\n";

my $conn = DBI->connect("DBI:Pg:dbname=my_awesome_day; host=localhost", 'pg_user', '564564') || die "Could not connect to database";

my $cgi = CGI->new;
my $name = $cgi->param("user_name");
my $uid = $cgi->param("u_id");
my $link = $cgi->param("link");

my $scmd = "SELECT * FROM users WHERE fb_id = ?";
my $rows = $conn->prepare($scmd);
$rows->execute($uid) || die "couldnt fetch users\n"; 

if($rows->rows == 0) {
	my $cmd = "INSERT INTO users(name,fb_id,link) VALUES(?,?,?)";
	my $sth = $conn->do($cmd,undef,$name,$uid,$link)|| die "couldnt insert into users\n";	
}

my $response = "{\"name\" : \"$name\", \"status\" : \"OK\"}";

print $response;

