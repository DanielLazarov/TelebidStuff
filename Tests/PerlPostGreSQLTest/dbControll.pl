use DBI;
use strict;
use Term::ReadKey;


my $conn = conEstablish();
insertNewEquipment($conn);

sub conEstablish{
    my $conn;
    START:
    my $result = eval{

	    print "Enter Username \n";
	    chomp(my $username = <STDIN>);

	    print "Enter Password \n";
        ReadMode('noecho'); # don't echo
        chomp(my $password = <STDIN>);
        ReadMode(0);        # back to normal
	    
	    print "Enter hostname \n";
	    chomp(my $hostname = <STDIN>);

	    print "Enter database Name \n";
	    chomp(my $dbname = <STDIN>);

	    #print "name: $username \n";
	    #print "pw: $password \n";
	    #print "hostname: $hostname \n";
	    #print "db: $dbname \n";
	    $conn = DBI->connect("DBI:Pg:dbname=$dbname;host=$hostname", $username, $password);
    };
    unless($result) {
        warn $@;
        goto START;
    }
    print "Connected!\n";
	return $conn;
}

sub writeToDB{
    my ($conn) = @_;
    my $command;
    my $result = eval {
        print "Type SQL commands here: \n";
        chomp($command = <STDIN>);    
        my $sth = $conn->prepare($command);
        $sth->execute();
    };
    unless($result){
    warn $@;
    }
}
sub insertParams{
	my ($conn) = @_;

    #TODO data validation 
    #START:
    print "Enter Type \n";
    chomp(my $type = <STDIN>);

    print "Enter Color \n";
    chomp(my $color = <STDIN>);

    print "Enter Location \n";
    chomp(my $location = <STDIN>);

    while(!eval {
        $conn->do("INSERT INTO pg_equipment (type, color, location, install_date) 
                VALUES (\'$type\',\'$color\', \'$location\',      CURRENT_DATE)");
        };) {
        print "can't connect!";
        $conn = conEstablish();   
    }                           
}

$conn->disconnect();

