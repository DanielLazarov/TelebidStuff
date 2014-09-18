#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use Try::Tiny;

my $dbName = "";
my $host = "";
my $dbUser = "";
my $dbUserPW = "";

my $table = "";
my $colRenameFrom = "";
my $colRenameTo = "";

my $dir = "";
my $suffix = ".png";

my $dbh;
my $statement;
my $sth;

try
{	
	$dbh = DBI->connect("DBI:Pg:dbname=$dbName; host=$host", $dbUser, $dbUserPW);
	my $col1 = $dbh->quote_identifier($colRenameFrom);
	my $col2 = $dbh->quote_identifier($colRenameTo);
	my $tab = $dbh->quote_identifier($table);
	$statement = "SELECT $col1, $col2 FROM $tab";
	$sth = $dbh->prepare($statement);
	$sth->execute();

	while(my $rv = $sth->fetchrow_hashref())
	{
		my $fileToRename = $dir . $rv->{$colRenameFrom} . $suffix;
		my $newName = $dir . $rv->{$colRenameTo} . $suffix;
	}
}
catch
{
	warn "caught error: $_";
};	
print "done\n";
