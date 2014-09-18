use Classes::Animals;
use Term::ReadKey;
use DBI;
use strict;
use Switch;

menu();

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

sub menu {
	my $choice;
	#my $conn = conEstablish();
	my $conn = DBI->connect("DBI:Pg:dbname=my_pg_db;host=localhost", "pg_user", "564564");
	my $check = 1;
	while($check) {	
		print "What would you like to do?\n";
		print "  1.Create Animal \n";
		print "  2.Delete Animal \n";
		#print "  3.Delete Animal \n";
		print "  3.Create Vet \n\n";
		#print "  5.Search Vet \n";
		#print "  6.Delete Vet \n";
		print "  4.Exit \n";
		chomp ($choice = <STDIN>);
		switch($choice){
			case 1 {animalReg($conn)}
			#case 2 {animalSrc($conn)}
			case 2 {animalDel($conn)}
			case 3 {vetReg($conn)}
			#case 5 {vetSrc()}
			#case 6 {vetDel()}	
			case 4  {$check = 0; $conn->disconnect();}
		}
	}		
}
sub animalSrc {
	my($conn) = @_;
	my $sth;

	#RANDOM TEST SELECT STATEMENT
	print "The first 10 Animals sorted by type, Named asen with vet name Pesho \n";
	$sth = $conn->prepare("SELECT animals.a_id, animals.vaccinated, animals.type FROM animals JOIN vets ON animals.vet_id = vets.id WHERE animals.name = ? AND vets.first_name = ? ORDER BY type LIMIT 10");
	$sth->execute("asen", "Pesho");	
	
	while(my $ref = $sth->fetchrow_arrayref()) {
		print "@{$ref} \n";
	}

}

sub animalReg {
	my($conn) = @_;
	print "Enter Animal's type \n";
	chomp(my $type = <STDIN>);
	print "Enter Animal's name \n";
	chomp(my $name = <STDIN>);
	print "Enter Animal's gender (male or female) \n";
	chomp(my $gender = <STDIN>);
	print "Enter Animal's vet Number\n";
	chomp(my $vetNo = <STDIN>);	
	print "Animal is vaccinated (t/f)? \n";
	chomp(my $vacine = <STDIN>);
	
	makeAnimal($conn, $type, $name, $gender, $vetNo, $vacine);

}

sub makeAnimal {
	my ($conn, $type, $name, $gender, $vetNo, $vacine) = @_;
	
	my $cmd = "INSERT INTO animals (type, name, gender, vet_id, vaccinated) VALUES (?,?,?,?,?)";
	$conn->do($cmd, undef, $type,$name,$gender,$vetNo,$vacine);
	#my $sth = $conn->prepare($cmd);
	#$sth->execute($type,$name,$gender,$vetNo,$vacine);
	#$sth->finish();	
}

sub vetReg {
	my($conn) = @_;
	print "Enter Vet's First Name \n";
	chomp(my $nameF = <STDIN>);
	print "Enter Vet's Mid Name \n";
	chomp(my $nameM = <STDIN>);
	print "Enter Vet's Last Name \n";
	chomp(my $nameL = <STDIN>);
	print "Enter Vet's Phone Numober \n";
	chomp(my $phone = <STDIN>);
	print "Enter Vet's Address \n";
	chomp(my $address = <STDIN>);
	print "Enter Vet's years of experience \n";
	chomp(my $experienceYears = <STDIN>);

	makeVet($conn, $nameF, $nameM, $nameL, $phone, $address, $experienceYears);
}

sub makeVet {
	my($conn, $nameF, $nameM, $nameL, $phone, $address, $experienceYears) = @_;
		
	my $sth = $conn->prepare("INSERT INTO vets (first_name, middle_name, last_name, phone, address, experience_years) VALUES (?,?,?,?,?,?)");	
	$sth->execute($nameF, $nameM, $nameL, $phone, $address, $experienceYears);
	$sth->finish();

}

sub animalDel {
	my($conn) = @_;
	print"Enter id of the Animal you want to delete: \n";
	chomp(my $id = <STDIN>); 
	my $cmd = "DELETE FROM animals WHERE a_id = ?";
	my $rows = $conn->do($cmd, undef, $id) || DBI::errst();
	if($rows == "0E0") {
		print "No animals killed";
	}
	else {
		print "$rows animals were deleted \n";
	}
}

sub animalSrc {
	my($conn) = @_;
	my $check = 1;
	while($check){
		print "Search animal by:\n";
		print "1.Id \n";
		print "2.Name \n";
		print "3.Type \n";
		print "4.Gender \n";
		print "5.Vaccine \n";
		print "6.Vet Id \n\n";
		print "8.Exit \n";

		chomp(my $input = <STDIN>);
		switch($choice){
			case 1 {
				
			}
			
		}
	}




