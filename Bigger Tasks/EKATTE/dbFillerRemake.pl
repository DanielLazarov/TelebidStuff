use Spreadsheet::ParseExcel;
use Archive::Extract;
use warnings;
use strict;
use DBI;
use Encode;
use LWP::Simple;
use Switch;
#Table schema at the bottom

START:
my $status = eval {
	while(1){
		my $start_run = time();
		fileUpdate();
		falsifier();
		main();
		my $end_run = time();
		my $run_time = $end_run - $start_run;
		print "Done!, Job took $run_time seconds\n";
		sleep 30;
	}
};

if($@) {
	print "$@ \n";
	sleep 10;
	goto START;
}

	

sub main {
	my @fNames = ('Ekatte/Ekatte_xls/Ek_doc.xls', 'Ekatte/Ekatte_xls/Ek_tsb.xls', 'Ekatte/Ekatte_xls/Ek_obst.xls', 'Ekatte/Ekatte_xls/Ek_kmet.xls', 'Ekatte/Ekatte_xls/Ek_sobr.xls', 'Ekatte/Ekatte_xls/Ek_raion.xls', 'Ekatte/Ekatte_xls/Ek_reg2.xls', 'Ekatte/Ekatte_xls/Sof_rai.xls', 'Ekatte/Ekatte_xls/Ek_obl.xls', 'Ekatte/Ekatte_xls/Ek_atte.xls');

	for(my $i = 0; $i <= $#fNames; $i++) {
		dbFiller($i,\@fNames);
	}
}
	
sub fileUpdate {
	my $status = getstore("http://www.nsi.bg/sites/default/files/files/EKATTE/Ekatte.zip", "ekatte.zip");
 
	if ( is_success($status) )
	{
 	 	print "file downloaded correctly\n";
		my $ae = Archive::Extract->new( archive => 'ekatte.zip' );
		my $ok = $ae->extract( to => 'Ekatte' );
		$ae = Archive::Extract->new( archive => 'Ekatte/Ekatte_xls.zip' );	
		$ok = $ae->extract( to => 'Ekatte/Ekatte_xls' );
		}
	else
	{
 	 	die "error downloading file: $status\n";
	}	
}

sub dbFiller {
	my($choice,$ref) = @_;
	my @arr = @{$ref};
	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564') || die "Could not connect to database";
	my $offset = 1;
	if($choice == 9) {
		$offset = 2;
	}

	my $FileName = $arr[$choice];
	my $parser   = Spreadsheet::ParseExcel->new();
	my $workbook = $parser->parse($FileName) || die $parser->error();

	for my $worksheet ( $workbook->worksheets() ) {
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();

		for my $row ( $row_min + $offset .. $row_max ) {
			my @data=();
			for my $col ( $col_min .. $col_max ) {

				my $cell = $worksheet->get_cell( $row, $col );
				next unless $cell;
				push(@data, $cell->value());
			}
			switch($choice) {
				case 0 {dbFillDocument($conn,\@data)}
				case 1 {dbFillTSB($conn,\@data)}
				case 2 {dbFillMunicipality($conn,\@data)}
				case 3 {dbFillTownHall($conn,\@data)}
				case 4 {dbFillSobr($conn,\@data)}
				case 5 {dbFillRaion($conn,\@data)}
				case 6 {dbFillRegion($conn,\@data)}
				case 7 {dbFillSofRai($conn,\@data)}
				case 8 {dbFillArea($conn,\@data)}
				case 9 {
					if(substr($data[5],-2) eq "00") {
						dbReFillTownHall($conn,\@data);
					} 
					dbFillEkatte($conn,\@data)
				}				
			}
		}
	}
	$conn->disconnect();
	print "done $arr[$choice]\n";
}
sub falsifier {	
	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564') || die "Could not connect to database";	
	my $updcmd = "UPDATE ek_area SET exists = ?";
	my $upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_area";
	$updcmd = "UPDATE ek_atte SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_atte";
	$updcmd = "UPDATE ek_sobr SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_sobr";
	$updcmd = "UPDATE ek_raion SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_raion";
	$updcmd = "UPDATE ek_region SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_region";
	$updcmd = "UPDATE sof_rai SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in sof_rai";	
	$updcmd = "UPDATE ek_town_hall SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_town_hall";
	$updcmd = "UPDATE ek_municipality SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_municipality";
	$updcmd = "UPDATE ek_tsb SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_tsb";
	$updcmd = "UPDATE ek_document SET exists = ?";
	$upd = $conn->do($updcmd,undef,'f') || die "can't update in ek_document";
	print "all existance is now false \n";
}

sub dbFillArea {
	my ($conn,$ref) = @_;
	my @data = @{$ref};

	my $ucmd = "UPDATE ek_area SET area = ?, ekatte = ?, name = ?, region = ?, document = ?, exists = ? WHERE area = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4], 't', $data[0]) || die "can't update 	in ek_area";
	print "rows updated of area: $usth\n";

	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_area (area,ekatte,name,region,document,exists) VALUES (?,?,?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],'t') || die "can't insert in ek_area";
	}
}

sub dbFillEkatte {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE ek_atte SET ekatte = ?, t_v_m = ?, name = ?, area = ?, municipality = ?, town_hall = ?, kind = ?, category = ?, altitude = ?, document = ?, tsb = ?, exists = ? WHERE ekatte = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],$data[6],$data[7],$data[8],$data[9],$data[10], 't', $data[0]) || die "can't update in ek_atte";
	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_atte(ekatte,t_v_m,name,area,municipality,town_hall,kind,category,altitude,document,tsb,exists) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],$data[6],$data[7],$data[8],$data[9],$data[10], 't') || die "can't insert in ek_atte";
	}
}

sub dbFillSobr {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	$data[4] = decode_utf8( $data[4] );
	my $ucmd = "UPDATE ek_sobr SET ekatte = ?,kind = ?, name = ?, area1 = ?, area2 = ?, document = ?, exists = ? WHERE ekatte = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],'t',$data[0]) || die "can't update in ek_sobr";
	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_sobr(ekatte,kind,name,area1,area2,document,exists) VALUES(?,?,?,?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],'t') || die "can't insert in ek_sobr";
	}
}

sub dbFillRaion {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE ek_raion SET raion = ?, name = ?, category = ?, document = ?, exists = ? WHERE raion = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],'t',$data[0]) || die "can't update in ek_raion";

	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_raion(raion,name,category,document,exists) VALUES(?,?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],'t') || die "can't insert in ek_raion";
	}
}

sub dbFillRegion {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE ek_region SET region = ?, name = ?, document = ?, exists = ? WHERE region = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],'t',$data[0]) || die "can't update in ek_region";

	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_region(region,name,document,exists) VALUES(?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],'t') || die "can't insert in ek_region";
	}
}

sub dbFillSofRai {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE sof_rai SET ekatte = ?, t_v_m = ?, name = ?, raion = ?, kind = ?, document = ?, exists = ? WHERE ekatte = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],'t',$data[0]) || die "can't update in sof_rai";
	if($usth eq "0E0") {
		my $cmd = "INSERT INTO sof_rai(ekatte,t_v_m,name,raion,kind,document, exists) VALUES(?,?,?,?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],'t') || die "can't insert in sof_rai";
	}
}

sub dbFillTownHall {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE ek_town_hall SET town_hall = ?, ekatte = ?, name = ?, category = ?, document = ?, exists = ? WHERE town_hall = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],'t',$data[0]) || die "can't update in town_hall";

	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_town_hall(town_hall,ekatte,name,category,document,exists) VALUES(?,?,?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],'t') || die "can't insert in town_hall";
	}
}

sub dbReFillTownHall {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	if(substr($data[5],-2) eq "00") {
		my $ucmd = "UPDATE ek_town_hall SET town_hall = ?, ekatte = ?, name = ?, category = ?, document = ?, exists = ? WHERE town_hall = ?";
		my $usth = $conn->do($ucmd,undef,$data[5],$data[0],$data[2],$data[7],$data[9],'t',$data[5]) || die "can't update in town_hall";
		if($usth eq "0E0") {
			my $cmd = "INSERT INTO ek_town_hall(town_hall,ekatte,name,category,document,exists) VALUES(?,?,?,?,?,?)";
			my $sth = $conn->do($cmd,undef,$data[5],$data[0],$data[2],$data[7],$data[9],'t') || die "can't insert in town_hall";
		}
	}
}

sub dbFillMunicipality {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE ek_municipality SET municipality = ?, ekatte = ?, name = ?, category = ?, document = ?, exists = ? WHERE municipality = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4], 't',$data[0]) || die "can't update in municipality";

	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_municipality(municipality,ekatte,name,category,document, exists) VALUES(?,?,?,?,?,?)";
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4], 't') || die "can't insert in municipality";
    }
}

sub dbFillDocument {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE ek_document SET document = ?, document_kind = ?, document_name = ?, document_inst = ?, document_num = ?, document_date = ?, document_act = ?, dv_data = ?, dv_date = ?, exists = ? WHERE document = ?";
		$data[4] = decode_utf8( $data[4] );
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],$data[6],$data[7],$data[8], 't', $data[0]) || die "can't update in document";

	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_document(document,document_kind,document_name,document_inst,document_num,document_date,document_act,dv_data,dv_date, exists) VALUES(?,?,?,?,?,?,?,?,?,?)";
		$data[4] = decode_utf8( $data[4] );
		my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],$data[6],$data[7],$data[8], 't') || die "can't insert in document";
	}
}

sub dbFillTSB {
	my ($conn,$ref) = @_;
	my @data = @{$ref};
	my $ucmd = "UPDATE ek_tsb SET tsb = ?,name = ?, exists = ? WHERE tsb = ?";
	my $usth = $conn->do($ucmd,undef,$data[0],$data[1],'t',$data[0]) || die "can't update in tsb";

	if($usth eq "0E0") {
		my $cmd = "INSERT INTO ek_tsb (tsb, name, exists) VALUES(?,?,?)";
		my $rows = $conn->do($cmd,undef,$data[0],$data[1], 't') || die "can't insert in tsb";
	}
}

##################################
#-------------TABLES-------------#
##################################

	#---can be first---#
#CREATE TABLE ek_tsb(
#id SERIAL PRIMARY KEY,
#tsb CHAR(2) NOT NULL UNIQUE,
#name VARCHAR(50)NOT NULL,
#exists boolean
#);

	#---can be first---#
#CREATE TABLE ek_document (
#id SERIAL PRIMARY KEY,
#document INTEGER NOT NULL UNIQUE,
#document_kind VARCHAR(50) NOT NULL,
#document_name TEXT NOT NULL,
#document_inst TEXT NOT NULL,
#document_num VARCHAR(50) NOT NULL,
#document_date DATE NOT NULL,
#document_act DATE,
#dv_data VARCHAR(50sobr),
#dv_date DATE,
#exists boolean
#);

	#---after ek_document---#
#CREATE TABLE ek_municipality(
#id SERIAL PRIMARY KEY,
#municipality CHAR(5) NOT NULL UNIQUE,
#ekatte CHAR(5) NOT NULL,
#name VARCHAR(100)NOT NULL,
#category INTEGER NOT NULL,
#document INTEGER REFERENCES ek_document(document),
#exists boolean
#);

	#---after ek_document---#
#CREATE TABLE ek_town_hall (
#id SERIAL PRIMARY KEY,
#town_hall CHAR(8) NOT NULL UNIQUE,
#ekatte CHAR(5) UNIQUE NOT NULL,
#name VARCHAR(100)NOT NULL,
#category INTEGER,
#document INTEGER REFERENCES ek_document(document),
#exists boolean
#);

	#---after ek_document---#
#CREATE TABLE ek_sobr(
#id SERIAL PRIMARY KEY,
#ekatte CHAR(5) UNIQUE NOT NULL,
#kind INTEGER NOT NULL,
#name VARCHAR(100)NOT NULL,
#area1 VARCHAR(100),
#area2 VARCHAR(100),
#document INTEGER REFERENCES ek_document(document),
#exists boolean
#);

	#---after ek_document---#
#CREATE TABLE ek_raion(
#id SERIAL PRIMARY KEY,
#raion CHAR(8) NOT NULL UNIQUE,
#name VARCHAR(100) NOT NULL,
#category INTEGER,
#document INTEGER REFERENCES ek_document(document),
#exists boolean
#);

	#---after ek_document---#
#CREATE TABLE ek_region(
#id SERIAL PRIMARY KEY,
#region CHAR(4) NOT NULL UNIQUE,
#name VARCHAR(100) NOT NULL,
#document INTEGER REFERENCES ek_document(document),
#exists boolean
#);

	#---after ek_document and ek_raion---#
#CREATE TABLE sof_rai(
#id SERIAL PRIMARY KEY,
#ekatte CHAR(5) UNIQUE NOT NULL,
#t_v_m VARCHAR(25),
#name VARCHAR(100) NOT NULL,
#raion CHAR(8) NOT NULL REFERENCES ek_raion(raion),
#kind INTEGER NOT NULL,
#document INTEGER REFERENCES ek_document(document),
#exists boolean
#);

	#---after ek_region and ek_document---#
#CREATE TABLE ek_area(
#id SERIAL PRIMARY KEY,
#area CHAR(3) NOT NULL UNIQUE,
#ekatte CHAR(5) NOT NULL,
#name VARCHAR(100)NOT NULL,
#region CHAR(4) NOT NULL REFERENCES ek_region(region),
#document INTEGER REFERENCES ek_document(document),
#exists boolean
#);

	#---last---#
#CREATE TABLE ek_atte(
#id SERIAL PRIMARY KEY,
#ekatte CHAR(5) UNIQUE NOT NULL,
#t_v_m VARCHAR(25),
#name VARCHAR(100)NOT NULL,
#area CHAR(3) NOT NULL REFERENCES ek_area(area),
#municipality CHAR(5) NOT NULL REFERENCES ek_municipality(municipality),
#town_hall CHAR(8) NOT NULL REFERENCES ek_town_hall(town_hall),  			
#kind INTEGER NOT NULL,
#category INTEGER NOT NULL,
#altitude INTEGER NOT NULL,
#document INTEGER REFERENCES ek_document(document),
#tsb CHAR(2) NOT NULL REFERENCES ek_tsb(tsb),
#exists boolean
#);

