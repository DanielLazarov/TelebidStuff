#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use DBI;


#All rows from the tables related to the table from which a row will be deleted,
#having relation to the row that is about to be deleted, 
#will be changed to point to a row with name or serial(depending on the table),  

my $result ='{'; 

my $dbName = "office_devices";
my $host = "localhost";
my $user = "pg_user";
my $pw = "564564";

print "Content-type: application/json\n\n";

my $dbh = DBI->connect("DBI:Pg:dbname=$dbName; host=$host", $user, $pw, {
        AutoCommit => 0,	
        RaiseError => 1,
    }) or die "Could not connect to database";

my $cgi = CGI->new;
my $choice = $cgi->param("choice");

if($choice eq "computer") {
	my $serial = $cgi->param("serial");
	$result .= '"serial" :' . "\"$serial\",";

	eval {
		#Get the id of the PC 'none'
		#my $scmd = "SELECT id from computers WHERE serial_num = ?";
		#my $rows = $dbh->prepare($scmd);
		#$rows->execute('none') or die "couldnt fetch computers\n";
		#my $idref = $rows->fetchrow_hashref();
		#my $nopc_id = $idref->{'id'};
		#$result .= '"noneID" :' . "\"$nopc_id\",";

		#Get the real id of the PC for delete
		my $scmd = "SELECT id from computers WHERE serial_num = ?";
		my $rows = $dbh->prepare($scmd);
		$rows->execute($serial) or die "couldnt fetch computers\n";
		my $idref = $rows->fetchrow_hashref();
		my $pc_id = $idref->{'id'};
		$result .= '"pcID" :' . "\"$pc_id\"}";

		# #Unlink the hardware parts, linked to the PC for delete and link them to the PC 'none'
		# my $ucmd = "UPDATE hardware_parts SET computer_id = ? WHERE computer_id = ? ";
		# $rows = $dbh->prepare($ucmd);
		# $rows->execute($nopc_id,$pc_id) or die "couldnt fetch computers\n";
		# $result .= '"updated" :' . "\"parts\"}";

		# #Unlink the pictures, linked to the PC for delete and link them to the PC 'none'
		# $ucmd = "UPDATE computer_images SET computer_id = ? WHERE computer_id = ? ";
		# $rows = $dbh->prepare($ucmd);
		# $rows->execute($nopc_id,$pc_id) or die "couldnt fetch computers\n";
		# $result .= '"updated" :' . "\"images\"}";

		# #Unlink the pictures, linked to the PC for delete and link them to the PC 'none'
		# $ucmd = "UPDATE computer_manuals SET computer_id = ? WHERE computer_id = ? ";
		# $rows = $dbh->prepare($ucmd);
		# $rows->execute($nopc_id,$pc_id) or die "couldnt fetch computers\n";
		# $result .= '"updated" :' . "\"images\"}";

		#"Delete" the selected PC
		my $ucmd = "UPDATE computers  SET exists = ? WHERE serial_num = ?";
	 	$rows = $dbh->prepare($ucmd);
		$rows->execute('f',$serial) or die "couldnt fetch computers\n";
		$result .= '"deleted" :' . "\"$pc_id\"}";
		$rows->finish;
	};
	if(@!){
		my $response = '{"status": "FAILED"}';
		print $result;
		my $rc = $dbh->rollback;
	}
	else{
		my $response = '{"status": "OK"}';
		print $response;
		my $rc = $dbh->commit;
	}
}
$dbh->disconnect or warn "Disconnection error: $DBI::errstr\n";
