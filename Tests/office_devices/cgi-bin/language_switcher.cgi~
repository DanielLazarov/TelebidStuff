#!/usr/bin/perl
use warnings;
use strict;
use CGI qw/:standard/;

my $retrieve_language = cookie('language');

my $cgi = CGI->new;
my $language = $cgi->param("language");

my $languageCookie = CGI::Cookie->new(-name=>'language', -value=>$language);
print header(-cookie=>$languageCookie);
print '<meta http-equiv="refresh" content="0; url=https://10.20.2.104:442" />';




