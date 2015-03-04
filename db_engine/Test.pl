use warnings;
use strict;

use Data::Dumper;

use DanielDB::Engine;


my $db = DanielDB::Engine->connect("db_1");

my @columns = (
    {type => "int", name => "column1"}, 
    {type => "text", name => "column2"},
    {type => "text", name => "column3"},
    {type => "int", name => "column4"}
);
$db->CreateTable("table5", \@columns);

my $data = {
    column1 => 1024,
    column2 => "textcol1",
    column3 => "textcol2",
    column4 => 2000000
};
$db->Insert("table5", $data);
$db->Insert("table5", $data);
$db->Insert("table5", $data);

my $result = $db->Select("table5");
print Dumper $result;

$data = {"column2" => "UPDATED"};
$db->Update("table5", $data);

$result = $db->Select("table5");
print Dumper $result;
