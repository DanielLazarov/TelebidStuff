use Spreadsheet::ParseExcel;
use Archive::Extract;
use warnings;
use strict;
use DBI;
use Encode;
use LWP::Simple;

#fileUpdate();
#tsbFill();
#documentFill();
#municipalityFill();
#town_hallFill();
#sobrFill();
#raionFill();
#regionFill();
#sof_raiFill();
ek_areaFill();
#ek_atteFill();



#TODO less repeating code lines!
sub tsbFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_tsb.xls";
	my $parser   = Spreadsheet::ParseExcel->new();
	my $workbook = $parser->parse($FileName);

	die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
	for my $worksheet ( $workbook->worksheets() ) {

		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();

		for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
			for my $col ( $col_min .. $col_max ) {

				my $cell = $worksheet->get_cell( $row, $col );
				next unless $cell;
				push(@data, $cell->value());
			}
			#TODO fix character errors + data validation
			my $cmd = "INSERT INTO ek_tsb(tsb,name) VALUES(?,?)";
			my $sth = $conn->do($cmd,undef,$data[0],$data[1]) || DBI::errst();
		}
	}
	$conn->disconnect();
	print "tsb done!\n";
}

sub documentFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_doc.xls";
	my $parser   = Spreadsheet::ParseExcel->new();
	my $workbook = $parser->parse($FileName);

	die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
	for my $worksheet ( $workbook->worksheets() ) {

		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();

		for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
			for my $col ( $col_min .. $col_max ) {
				my $cell = $worksheet->get_cell( $row, $col );
				next unless $cell;

				push(@data, $cell->value());
			}
			my $cmd = "INSERT INTO ek_document(document,document_kind,document_name,document_inst,document_num,document_date,document_act,dv_data,dv_date) VALUES(?,?,?,?,?,?,?,?,?)";
			#TODO fix character errors + data validation
			$data[4] = decode_utf8( $data[4] );
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],$data[6],$data[7],$data[8]) || DBI::errst();
		}
	}
	$conn->disconnect();
	print "document done!\n";
}

sub municipalityFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_obst.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);

    die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());

            }
			#TODO fix character errors + data validation
			my $cmd = "INSERT INTO ek_municipality(municipality,ekatte,name,category,document) VALUES(?,?,?,?,?)";
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4]) || DBI::errst();
        }
    }
	$conn->disconnect();
	print "municipality done!\n";
}

sub town_hallFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_kmet.xls";
	my $OtherFileName = "Ekatte/Ekatte_xls/Ek_atte.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);
	my $workbook1 = $parser->parse($OtherFileName);

    die $parser->error(), ".\n" if ( !defined $workbook );
	die $parser->error(), ".\n" if ( !defined $workbook1 );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());

            }
			#TODO fix character errors + data validation
			my $cmd = "INSERT INTO ek_town_hall(town_hall,ekatte,name,category,document) VALUES(?,?,?,?,?)";
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4]) || DBI::errst();
        }
    }

	for my $worksheet1 ( $workbook1->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet1->row_range();
        my ( $col_min, $col_max ) = $worksheet1->col_range();

        for my $row ( $row_min + 2 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet1->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());

            }
			#TODO fix character errors + data validation
			if(substr($data[5],-2) eq "00")
			{	my $scmd = "SELECT * FROM ek_town_hall WHERE town_hall = ?";
				my $rows = $conn->prepare($scmd);
				$rows->execute($data[5]) || die "couldnt fetch ek_town_hall";
				if($rows->rows == 0) {
					my $cmd = "INSERT INTO ek_town_hall(town_hall,ekatte,name,category,document) VALUES(?,?,?,?,?)";
					my $sth = $conn->do($cmd,undef,$data[5],$data[0],$data[2],$data[7],$data[9]) || DBI::errst();
				}
				elsif($rows->rows > 1) {
					die "more than 1";
				} 
			}
        }
    }
	$conn->disconnect();
	print "town_hall done!\n";
}

sub sobrFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_sobr.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);

    die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());

            }
			#TODO fix character error in area 2 column.
			my $cmd = "INSERT INTO ek_sobr(ekatte,kind,name,area1,area2,document) VALUES(?,?,?,?,?,?)";
			$data[4] = decode_utf8( $data[4] );
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5]) || DBI::errst();
        }
    }
	$conn->disconnect();
	print "sobr done!\n";
}

sub raionFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_raion.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);

    die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());

            }
			#TODO fix character errors + data validation
			my $cmd = "INSERT INTO ek_raion(raion,name,category,document) VALUES(?,?,?,?)";
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3]) || DBI::errst();
        }
    }
	$conn->disconnect();
	print "raion done!\n";
}

sub regionFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_reg2.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);

    die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());
            }
			#TODO fix character errors + data validation
			my $cmd = "INSERT INTO ek_region(region,name,document) VALUES(?,?,?)";
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2]) || DBI::errst();
        }
    }
	$conn->disconnect();
	print "region done!\n";
}

sub sof_raiFill {

	my $FileName = "Ekatte/Ekatte_xls/Sof_rai.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);

    die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());
            }
			#TODO fix character errors + data validation
			my $cmd = "INSERT INTO sof_rai(ekatte,t_v_m,name,raion,kind,document) VALUES(?,?,?,?,?,?)";
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5]) || DBI::errst();
        }
    }
	$conn->disconnect();
	print "sof_rai done!\n";
}

sub ek_areaFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_obl.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);

    die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
	my $falsifier = "UPDATE ek_area SET exists = 'f'";
			$conn->do($falsifier);
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 1 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());
            }
			#TODO fix character errors + data validation		
			my $scmd = "SELECT * FROM ek_area WHERE area = ?";
			my $rows = $conn->prepare($scmd);
			$rows->execute($data[0]) || die "couldnt fetch ek_area";
			if($rows->rows == 0) {
				my $cmd = "INSERT INTO ek_area (area,ekatte,name,region,document,exists) VALUES (?,?,?,?,?,?)";
				my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],'t') || DBI::errst();
			}
			elsif($rows->rows > 1) {
				die "unique violation in ek_area";
			}
			else {
				my $cmd = "UPDATE ek_area SET area = ?, ekatte = ?, name = ?, region = ?, document = ?, exists = ? WHERE area = ?";
				my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4], 't', $data[0]) || DBI::errst();
			}
			
        }
    }
	$conn->disconnect();
	print "ek_area done!\n";
}

sub ek_atteFill {

	my $FileName = "Ekatte/Ekatte_xls/Ek_atte.xls";
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($FileName);

    die $parser->error(), ".\n" if ( !defined $workbook );

	my $conn = DBI->connect("DBI:Pg:dbname=ekatte;host=localhost", 'pg_user', '564564');
    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min + 2 .. $row_max ) {
			my @data=();
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;
				push(@data, $cell->value());
            }
			
			#TODO fix character errors + data validation
			my $cmd = "INSERT INTO ek_atte(ekatte,t_v_m,name,area,municipality,town_hall,kind,category,altitude,document,tsb) VALUES(?,?,?,?,?,?,?,?,?,?,?)";
			my $sth = $conn->do($cmd,undef,$data[0],$data[1],$data[2],$data[3],$data[4],$data[5],$data[6],$data[7],$data[8],$data[9],$data[10]) || DBI::errst();

        }
    }
	$conn->disconnect();
	print "ek_atte done!\n";
}

sub fileUpdate {
	my $status = getstore("http://www.nsi.bg/sites/default/files/files/EKATTE/Ekatte.zip", "ekatte.zip");
 
	if ( is_success($status) )
	{
 	 	print "file downloaded correctly\n";
	}
	else
	{
 	 	print "error downloading file: $status\n";
	}
	
	my $ae = Archive::Extract->new( archive => 'ekatte.zip' );
	my $ok = $ae->extract( to => 'Ekatte' );
	$ae = Archive::Extract->new( archive => 'Ekatte/Ekatte_xls.zip' );	
	$ok = $ae->extract( to => 'Ekatte/Ekatte_xls' );

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

