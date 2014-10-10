use Crypt::PBKDF2;
use DBI;
use Digest::SHA;

my $dbUser = "pg_user";
my $host = "localhost";
my $db = "office_devices";
my $pw = "564564";

my $conn = DBI->connect("DBI:Pg:dbname=".$db."; host=" . $host, $dbUser, $pw) || die "Could not connect to database";

my $sha = Digest::SHA->new('sha512');

 	my $name = "daniel";
    my $password = "parola";
    my $email = "daniel.r.lazarov@gmail.com";
    $sha->add($password, $name);

my $icmd = "INSERT INTO users(username,password,email) VALUES(?,?,?)";
my $rows = $conn->prepare($icmd);
$rows->execute($name, $sha->hexdigest, $email);
$conn->disconnect;
