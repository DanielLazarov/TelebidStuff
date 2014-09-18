#!/usr/bin/perl 
package Office::CustomDD;

use warnings;
use strict;

use CGI qw/:standard/;
use DBI;
use Encode;
use JSON;

my %HoF = (
    'network_id'  =>  \&customDropDownNetworks,
    'computer_id' =>  \&customDropDownComputers, 
    'model_id'    =>  \&customDropDownModels,
    'type_id'     =>  \&customDropDownTypes,
);


#----------------------Dispatcher--------------------------------

sub customDropDown($$)
{
	my($dbh, $params) = @_;
	$HoF{lc $$params{'choice'}}->($dbh, $$params{'cryteria'});
}

#################################################################

#----------------------Query Builders----------------------------
sub customDropDownNetworks($$)
{
    my ($dbh,$cryteria) = @_;
    $cryteria = lc decode_utf8($cryteria);
    my $valuecolumn = 'network_name_'. cookie('language');
    my $col1 = $dbh->quote_identifier($valuecolumn);
    my $query = "SELECT * FROM networks 
                    WHERE network_name_en = 'No Network' 
                        UNION ALL (
                    SELECT * FROM networks 
                    WHERE lower($col1) LIKE ? 
                    AND network_name_en <> 'No Network'
                    ORDER BY hits DESC
                    LIMIT 10)";

    return fillCustomDropDown($query, $valuecolumn, $dbh, $cryteria);  
}
sub customDropDownComputers($$)
{
    my ($dbh,$cryteria) = @_;
    $cryteria = lc decode_utf8($cryteria);
    my $valuecolumn = 'serial_num';
    my $col1 = $dbh->quote_identifier($valuecolumn);
    my $query = "SELECT * FROM computers 
                    WHERE computer_name_en = 'No Computer' 
                        UNION ALL (
                    SELECT * FROM computers 
                    WHERE lower($col1) LIKE ? 
                    AND computer_name_en <> 'No Computer'
                    ORDER BY date_updated DESC
                    LIMIT 10)";

    return fillCustomDropDown($query, $valuecolumn, $dbh, $cryteria);    
}
sub customDropDownModels($$)
{
    my ($dbh,$cryteria) = @_;
    $cryteria = lc decode_utf8($cryteria);
    my $valuecolumn = 'model';
    my $col1 = $dbh->quote_identifier($valuecolumn);
    my $query = "SELECT * FROM models 
                    WHERE lower($col1) LIKE ? 
                    ORDER BY date_updated DESC
                    LIMIT 10";

    return fillCustomDropDown($query, $valuecolumn, $dbh, $cryteria);    
}
sub customDropDownTypes($$)
{
    my ($dbh,$cryteria) = @_;
    $cryteria = lc decode_utf8($cryteria);
    my $valuecolumn = 'type';
    my $col1 = $dbh->quote_identifier($valuecolumn);
    my $query = "SELECT * FROM types 
                    WHERE lower($col1) LIKE ? 
                    ORDER BY date_updated DESC
                    LIMIT 10";

    return fillCustomDropDown($query, $valuecolumn, $dbh, $cryteria);    
}
################################################################


#-------------------------Result parser-------------------------
#Returns JSON-formated string.
sub fillCustomDropDown($$$$)
{
    my($query, $valuecolumn, $dbh, $cryteria) = @_;

	my @dataArr;

    my $rows = $dbh->prepare($query);
    $rows->execute('%'.$cryteria.'%');

    while(my $ref = $rows->fetchrow_hashref()) {
		my %dataObj = ('value' => decode_utf8( $ref->{$valuecolumn} ), 'id' => $ref->{'id'});
		my $dataObjRef = \%dataObj;
		push @dataArr, $dataObjRef;
    }
	
	my $dataArrRef = \@dataArr;
        
    my %responseh = ('content' => $dataArrRef);
    return \%responseh;
}
################################################################

1;
__END__
