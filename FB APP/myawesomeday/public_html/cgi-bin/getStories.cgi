#!/usr/bin/perl -w
use CGI qw(:standard);
use JSON;
use DBI;

print header('application/json');

my $conn = DBI->connect("DBI:Pg:dbname=my_awesome_day; host=localhost", 'pg_user', '564564') || die "Could not connect to database";

my $cgi = CGI->new;
my $uid = $cgi->param("u_id");

my $scmd = "SELECT name,date FROM stories WHERE user_id = ?";
my $rows = $conn->prepare($scmd);
$rows->execute($uid) || die "couldnt fetch users\n"; 
open FILE, ">file.txt" or die $!;
print FILE $uid . "\n";

if($rows->rows == 0) {
	print FILE "0 rows\n";
	my $response = '{"status":"NO-STORIES-FOUND"}';
	print $response;
}
else{
	print FILE $rows->rows . " rows\n";
	my $response = '{"status":"OK","story":[';
	my $comma = 0;
	while(my $ref = $rows->fetchrow_hashref()) {
		if($comma) { $response .= ",";}
		$response .= '{"name":' . "\"$ref->{'name'}\"," . '"date":' . "\"$ref->{'date'}\"}";
		$comma = 1; 
	}
	$response .= "]}";
	print FILE $response . "\n";
	#my $decoded;
	#my $eval = eval{
	#	$decoded = JSON::XS::decode_json($response);
	#};
	#if($@){
	#	warn $@;
	#}    		
	#my $json_text = to_json($response);
	print $response;
}
 close FILE;
