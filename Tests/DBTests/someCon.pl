use strict;
use warnings;
use DBI;

my $mId = 1;
my $conn = DBI->connect("DBI:Pg:dbname=my_pg_db;host=localhost", 'pg_user', '564564');
my $sth = $conn->prepare("SELECT id,name FROM sample WHERE manager_id = ? ORDER BY id DESC");

