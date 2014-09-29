use strict;
use warnings;

use WWW::Mechanize;
use utf8;

if(!$ARGV[0])
{
    print "Input parameters expected, Type \"perl grade.pl -h\" for help\n";
}
else
{
    if($ARGV[0] eq "-h")
    {
      print  "Usage: perl grade.pl [--] [arguments]\n 
        -p [file_name]    uses a specified profile file from the profiles directory as an argument\n 
        -i [args]         takes as arguments [egn faculty_num email time_interval(in seconds)], if not specified the interval will be 3600\n"; 
	}
    elsif($ARGV[0] eq "-p")
    {
        if(!$ARGV[1])
        {
            print "Please specify a profile name\n";
        }
        else
        {
            terminalFileInput();
        }
    }
    elsif($ARGV[0] eq "-i")
    {
        terminalArgumentsInput();
    } 
    else
    {
        print "Invalid option, Type \"perl grade.pl -h\" for help\n";
    }

}

sub terminalFileInput
{
	open (FH, "< profiles/$ARGV[1]") or die $!;
	my @lines = <FH>;
	close FH or die $!; 
	checkGrade($lines[0]=~/<(.*)>/, $lines[1]=~/<(.*)>/, $lines[2]=~/<(.*)>/, $lines[3]=~/<(.*)>/);
}

sub terminalArgumentsInput
{
    if($ARGV[1] && $ARGV[2] && $ARGV[3])
    {
      checkGrade($ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4] ? $ARGV[4] : 3600);  
    }       
    else
    {
        print "at least 3 arguments are expected [egn] [faculty_num] [email]\n";
    }
}

sub checkGrade 
{
  	my ($egn, $fn, $mailTo, $checkInterval) = @_;
	my $url = "http://student.tu-sofia.bg/marks.php";
	my $fileName = 'grades.txt';
	my $from = "webmaster\@daniel-pc.com";
	my $subject = 'Brace yourself, grades are comming!';
	
	my $valid = 1;
	while ($valid) 
	{
		my $result = eval {
			my $mech = WWW::Mechanize->new();

			$mech->get($url);
			$mech->form_name("studlogin");
			$mech->field('egn' => $egn);
			$mech->field('fn' => $fn);
			$mech->submit();

			$mech->get($url);	
			my $body = $mech->content;

			if($body!~/(Оценки)/)
			{
				TRACE("Incorrect login information");
				$valid = 0;
			}
			else
			{
				if (-e $fileName) 
				{	
					local $/;
					open(FILE, $fileName) or die $!;  
					my $document = <FILE>; 
					close (FILE);
					chomp $body;
					chomp $document;	

					utf8::encode( $body );
					if($document ne $body)
					{
						open(MAIL, "|/usr/sbin/sendmail -t");
						print MAIL "From: $from\n";
						print MAIL "To: $mailTo\n";
						print MAIL "Subject: $subject\n";
						print MAIL "Mime-Version: 1.0\n";
						print MAIL "Content-Type: text/html\n\n";
						print MAIL $body;
						close(MAIL);

						TRACE("Email Sent To $mailTo");

						open FILE, "> $fileName" or die $!;
						print FILE $body;
						close FILE;
					}			
				} 
				else 
				{
					$mech->get( $url, ':content_file' => $fileName);				
				}
			}
		};
		if(!$result)
		{
			TRACE($@);
		}
		if($valid)
		{
			sleep $checkInterval;
		}	
	}
}

sub TRACE($;$)
{

	my($string, $value) = @_;
	if(!defined $value)
	{
		$value = "";
	}
	print STDERR "[" . localtime . "] " . $string . ": " . $value . "\n";

}
