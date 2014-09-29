#!/usr/bin/perl

use strict; 
use warnings;

my $hostname = `hostname`;
my $this_day = `date`;
my $to = "daniellazarovmail93\@gmail.com";
my $from = "webmaster\@$hostname";
my $subject = "SCHEDULE COMPLETE - $this_day";
my $message = "<html><body><h1>This is a test.</h1></body></html>";



open(MAIL, "|/usr/sbin/sendmail -t");
print MAIL "From: $from";
print MAIL "To: $to\n";
print MAIL "Subject: $subject";
print MAIL "Mime-Version: 1.0\n";
print MAIL "Content-Type: text/html\n\n";
print MAIL $message;
close(MAIL);





#my $send_to = "To: ".$query->param('send_to'); 
#open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
#print SENDMAIL $reply_to;
#print SENDMAIL $subject;
#print SENDMAIL $send_to;
#print SENDMAIL "Content-type: text/plain\n\n";
#print SENDMAIL $content;
#close(SENDMAIL);
