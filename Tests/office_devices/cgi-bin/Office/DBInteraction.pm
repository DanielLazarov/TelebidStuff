#!/usr/bin/perl 
package Office::DBInteraction;

use strict;
use warnings;

use Apache::DBI;
use DBI;
use Encode;
use Try::Tiny;
use Data::Dumper;
use File::Basename;
use CGI qw/:standard/;

sub insertOrUpdateRecord($$)
{ 
    my ($dbh,$cgi) = @_;

    my @paramNames = $cgi->param;

    my @values;
    my @manualFiles;
    my @imageFiles;

    for(my $i = 0; $i <= $#paramNames; $i++)
    {
        if($cgi->param($paramNames[$i]) && $paramNames[$i] ne 'choice' && $paramNames[$i] ne 'add_btn' && $paramNames[$i] ne 'action' && $paramNames[$i] ne 'json_rpc' && $paramNames[$i] ne 'data_type')
        {
            my $length = scalar @values;
            if($paramNames[$i]=~/manual/)
            {
                my @handlers = $cgi->upload($paramNames[$i]);
                push(@manualFiles, @handlers);
            }
            elsif($paramNames[$i]=~/image/)
            {
                my @handlers = $cgi->upload($paramNames[$i]);
                push(@imageFiles, @handlers);
            }
            else
            {
                $values[$length][0] = $paramNames[$i];
                $values[$length][1] = $cgi->param($paramNames[$i])
            }
        }
    }

    my $arrSize = @values;
    $values[$arrSize][0] = 'last_modified_by';
    $values[$arrSize][1] = cookie('username');

    my $tcmd = "INSERT INTO " . $dbh->quote_identifier($cgi->param('choice')) 
    . "(" . join(",", map { $dbh->quote_identifier($$_[0]) } @values) 
    . ") VALUES(" . join( ',', map { '?' } @values ) 
    . ") RETURNING id";    
    my $sth = $dbh->prepare($tcmd);
    my @binded;
    for(my $i = 0; $i <= $#values; $i++)
    {
        push(@binded, $values[$i][1]);
    }
    $sth->execute(@binded);
    my $row = $sth->fetchrow_hashref();
    my $returnedID = $$row{id};

    if($imageFiles[0])
    {
        uploadFile($dbh,$cgi,$returnedID,'images',\@imageFiles);
    } 

    if($manualFiles[0])
    {
        uploadFile($dbh,$cgi,$returnedID,'manuals',\@manualFiles);
    }

    $dbh->commit;

    my %response = ('message' => 'Done');
    return \%response;  
}

sub uploadFile($$$$)
{
    my ($dbh,$cgi,$id,$choice,$handlersRef) = @_;
    my @handlers = @$handlersRef;
    my $upload_dir = "/home/daniel/Repositories/TelebidStuff/Tests/office_devices/uploads/".$cgi->param('choice');

    for(my $i = 0; $i <= $#handlers; $i++)
    {
        my($filename, $path, $suffix) = fileparse($handlers[$i], qr/\.[^.]*/);
        my $newname = $cgi->param('choice'). $id . $suffix;

        my $cmd = "INSERT INTO  " .  $dbh->quote_identifier($choice) . "(file_name,foreign_table,foreign_id,last_modified_by) VALUES (?,?,?,?) RETURNING id";
        my $sth = $dbh->prepare($cmd);
        $sth->execute($newname,$cgi->param('choice'),$id,cookie('username'));
        my $row = $sth->fetchrow_hashref();
        my $returnedID = $$row{id};

        $newname = $upload_dir . "/" . $choice . "/" . $returnedID . $newname;


        open ( UPLOADFILE, "> " . $newname ) or die "$!";
        binmode UPLOADFILE;
        my $handler = $handlers[$i]->handle;
        while ( <$handler> )
        {
            print UPLOADFILE;
        }
        close UPLOADFILE;

        $cmd = "UPDATE " . $dbh->quote_identifier($cgi->param('choice')) . " SET " . $dbh->quote_identifier('has_' . $choice) . " = ? WHERE id = ?";
        $sth = $dbh->prepare($cmd);
        $sth->execute('t',$id);
    }
}

1;
__END__
