use strict;
use warnings;
use File::Compare;
use WWW::Mechanize;
use HTTP::Cookies;
use LWP::Debug qw(+);
use MIME::Lite;
use Tk;
use open qw/:std :utf8/;

#Uncomment the one you want to use!
	#windowFullInput();
	#windowFileInput();
	terminalFileInput();

sub windowFileInput {
	my $result = eval {
		our $main = MainWindow->new();
		my $labelFileName = $main->Label(-text=>"File Name");
		my $labelCheckInterval = $main->Label(-text=>"Check Interval:");

		our $entryFileName = $main->Entry();
		our $entryCheckInterval = $main->Entry();
	
		$entryFileName->bind("<Return>", \&handle_return );
		$entryCheckInterval->bind("<Return>", \&handle_return );

		$entryCheckInterval->pack(-side=>"bottom");
		$labelCheckInterval->pack(-side=>"bottom");
		$entryFileName->pack(-side=>"bottom");
		$labelFileName->pack(-side=>"bottom");

		MainLoop;
		sub handle_return {
			my $fileName = $entryFileName->get();
			my $checkInterval = $entryCheckInterval->get();
			$main->destroy();

			open (FH, "< Profiles/$fileName.txt") or die "Can't open $fileName for read: $!";
			my @lines = <FH>;
			close FH or die "Cannot close $fileName: $!"; 
			checkGrade($lines[0], $lines[1], $lines[2], $checkInterval);
			exit;		
		}
	};
	if(!$result) {
		print $@;
	}
}

sub windowFullInput {
	my $result = eval {
		our $main = MainWindow->new();
		my $labelEGN = $main->Label(-text=>"EGN:");
		my $labelFN = $main->Label(-text=>"FN:");
		my $labelMail = $main->Label(-text=>"eMail:");
		my $labelCheckInterval = $main->Label(-text=>"Check Interval:");

		our $entryEGN = $main->Entry();
		our $entryFN = $main->Entry();
		our $entryMail = $main->Entry();
		our $entryCheckInterval = $main->Entry();

		$entryEGN->bind("<Return>", \&handle_returnf );
		$entryFN->bind("<Return>", \&handle_returnf );
		$entryMail->bind("<Return>", \&handle_returnf );
		$entryCheckInterval->bind("<Return>", \&handle_returnf );

		$entryCheckInterval->pack(-side=>"bottom");
		$labelCheckInterval->pack(-side=>"bottom");
		$entryMail->pack(-side=>"bottom");
		$labelMail->pack(-side=>"bottom");
		$entryFN->pack(-side=>"bottom");
		$labelFN->pack(-side=>"bottom");
		$entryEGN->pack(-side=>"bottom");
		$labelEGN->pack(-side=>"bottom");

		MainLoop;
		sub handle_returnf {
			my $EGN = $entryEGN->get();
			my $FN = $entryFN->get();
			my $Mail = $entryMail->get();
			my $checkInterval = $entryCheckInterval->get();
			$main->destroy();
			checkGrade($EGN, $FN, $Mail, $checkInterval);
			exit;		
		}
	};
	if(!$result) {
		print $@;
	}
}


sub terminalFileInput{
	my $result = eval {
		open (FH, "< Profiles/$ARGV[0].txt") or die "Can't open $ARGV[0] for read: $!";
		my @lines = <FH>;
		close FH or die "Cannot close $ARGV[0]: $!"; 
		checkGrade($lines[0], $lines[1], $lines[2], $lines[3]);
	};
	if(!$result) {
		print $@;
	}
}

sub checkGrade {
  	my ($egn, $fn, $mailTo, $checkInterval) = @_;
	my $urlLogIn = "http://student.tu-sofia.bg";
	my $url = "http://student.tu-sofia.bg/marks.php";
	my $fileName = 'grades.txt';
	my $currentFileName = 'tempgrades.txt';
	my $from = 'webmaster@DanielLazarov.com';
	my $subject = 'Brace yourself, grades are comming';
	
	START:
	while (1) {
		my $result = eval {
			my $mech = WWW::Mechanize->new();

			$mech->cookie_jar(HTTP::Cookies->new());
			$mech->get($urlLogIn);
			$mech->form_name("studlogin");
			
			$mech->field('egn' => $egn);
			$mech->field('fn' => $fn);
			$mech->submit();
		
			if (-e $fileName) {	
	
			#File Comparison (2 files)
				#$mech->get( $url, ':content_file' => $currentFileName);	
			 	#$mech->get($url);
				#my $body = $mech->content;

				#if (compare($fileName,$currentFileName) == 0) {
				#	unlink $currentFileName;
				#	 #print "equal\n"
				#}

				#else {	
				#	my $msg = MIME::Lite->new(
			   	#				 			From    => $from,
				#							To      => $mailTo,
				#							Subject => $subject,
				#						#HTML Message
				#							Type    =>'text/html',
				#							Data    => $body
				#							 );	
				#	$msg->send;
				
				#	print "Email Sent Successfully to $mailTo \n";
				#	#print $body;
				#	unlink $fileName;
				#	rename $currentFileName, $fileName;
				#}
	
			#String Comparison (1 file only) 
				local $/;
				open(FILE, $fileName) or die "Can't read file 'filename' [$!]\n";  
				my $document = <FILE>; 
				close (FILE);
				$mech->get($url);	
				my $body = $mech->content;
				chomp $body;
				chomp $document;		
				
				if($document ne $body){
					print "not equal!";
							
					my $msg = MIME::Lite->new(
			   					 			From     => $from,
											To       => $mailTo,
											Subject  => $subject,
											Type     =>'text/html',
											Data     => $body
											 );	               
					$msg->send;
					print "Email Sent Successfully to $mailTo \n";
					open(my $fh, '>', $fileName);
					print $fh $body;
					close $fh;
				}			
			} 

			else {
				$mech->get( $url, ':content_file' => $fileName);
						
			}
			print "done\n";
		};

		if(!$result) {
			print $@;
		}
		
		sleep $checkInterval;
	}
	goto START;
}










