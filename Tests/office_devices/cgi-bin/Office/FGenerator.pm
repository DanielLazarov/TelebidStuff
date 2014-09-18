#!/usr/bin/perl 
package Office::FGenerator;

use strict;
use warnings;

use HTML::Template;
use DBI;
use CGI qw/:standard/;

my $cgi = CGI->new;

my $action = "../perl/dispatcher.pl";
my $enctype = "multipart/form-data";
my $method = "post";

my %submit =(
        "bg" => "Добавяне",
        "en" => "Add"
); 
my %edit =(
        "bg" => "Запазване",
        "en" => "Save"
); 
my %delete =(
        "bg" => "Изтриване",
        "en" => "Delete"
); 
my %cancel =(
        "bg" => "Отмяна",
        "en" => "Cancel"
); 
sub generateForm($$)
{
    #my($dbh, $form, $key, $keyValue) = @_;
    my($dbh, $params) = @_;
    my $form = $$params{'form'};
    my $key = $$params{'key'};
    my $keyValue = $$params{'key_value'};

    my $formData = "";

    my $inforef;
    my $isEdit = 0;
    if($key && $keyValue)
    {
        $isEdit = 1;
        my $table = $dbh->quote_identifier($form);
        my $tableKey = $dbh->quote_identifier($key);

        my $scmd = "SELECT * FROM $table WHERE $tableKey = ?";
        my $sth = $dbh->prepare($scmd);
        $sth->execute($keyValue);
        $inforef = $sth->fetchrow_hashref();

    }

    my $cmd = "SELECT * FROM meta_data_inputs WHERE is_input = 't' AND table_name = ? ORDER BY ordering";
    my $sth = $dbh->prepare($cmd);
    $sth->execute($form);

    my $formTemplate = HTML::Template->new(filename => '/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/templates/form.tmpl');
    my $tableTemplate = HTML::Template->new(filename => '/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/templates/result-table.tmpl');
    my $buttonTemplate;

    if($isEdit)
    {
        $buttonTemplate = HTML::Template->new(filename => '/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/templates/edit_buttons.tmpl');
    }
    else
    {
        $buttonTemplate = HTML::Template->new(filename => '/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/templates/add_button.tmpl');
    }

    while(my $row = $sth->fetchrow_hashref())
    {
        my $required="";
        my $requiredField = "";
        my $valueToAdd = "";

        if($row->{'required'})
        {
            $required = "*";
            $requiredField = "required";
        }
        if($isEdit)
        {
            if($$row{'foreign_to'})
            {
                my $foreignTable = $dbh->quote_identifier($$row{'foreign_to'});
                my $foreignKeyColumn = $dbh->quote_identifier($$row{'foreign_key_column'});
                my $foreignValueColumn = $$row{'foreign_value_column_'.cookie('language')};

                my $innercmd = "SELECT * FROM $foreignTable WHERE $foreignKeyColumn = ?";
                my $innerSth = $dbh->prepare($innercmd);
                $innerSth->execute($$inforef{$$row{'column_name'}});
                my $innerRow = $innerSth->fetchrow_hashref();
                $valueToAdd = $$innerRow{$foreignValueColumn};
            }
            else
            {
                $valueToAdd = $$inforef{$$row{'column_name'}};
            }
        }
        else
        {
            $valueToAdd = $$row{'default_value_' . cookie('language')};
        }
        #----------Input template
        if(substr($row->{'input_type'},0,6) !~ /custom/)
        {
            my $inputTemplate = HTML::Template->new(filename => '/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/templates/input.tmpl');
            $inputTemplate->param(NAME => $row->{'name'});
            $inputTemplate->param(LABEL => $required . $row->{'label_'.cookie('language')});
            $inputTemplate->param(TYPE => $row->{'input_type'});
            $inputTemplate->param(ID => $row->{'name'} . "-" . $row->{'input_type'});
            $inputTemplate->param(CLASS => $row->{'name'} . "-" . $row->{'input_type'});
            $inputTemplate->param(VALUE => $valueToAdd);
            $inputTemplate->param(REQUIRED => $requiredField);
            if($row->{'input_type'} eq 'file')
            {
               $inputTemplate->param(MULTIPLE => 'multiple'); 
            }
            $formData .= $inputTemplate->output();

        }
        elsif($row->{'input_type'} eq "custom-dropdown-search")
        {
            my $inputTemplate = HTML::Template->new(filename => "/home/daniel/Repositories/TelebidStuff/Tests/office_devices/pages/templates/" . $row->{'input_type'} . ".tmpl");
            $inputTemplate->param(NAME => $row->{'name'});
            $inputTemplate->param(LABEL => $required . $row->{'label_'.cookie('language')});
            $inputTemplate->param(ID => $row->{'name'} . "-" . $row->{'input_type'});
            $inputTemplate->param(CLASS => $row->{'name'} . "-" . $row->{'input_type'});
            $inputTemplate->param(VALUE => $valueToAdd);
            $inputTemplate->param(DROPDOWNVALUE => $row->{'default_value_'.cookie('language')});
            $inputTemplate->param(KEY => $row->{'default_key'});
            $inputTemplate->param(ADD => $submit{cookie('language')});
            $inputTemplate->param(REQUIRED => $requiredField);
            $inputTemplate->param(GENERATE => $row->{'foreign_to'});
            $formData .= $inputTemplate->output();
        }
    }
    if($isEdit)
    {
        $buttonTemplate->param(SAVECHANGES => $edit{cookie('language')});
        $buttonTemplate->param(DELETE => $delete{cookie('language')});
        $buttonTemplate->param(CANCEL => $cancel{cookie('language')});
        $buttonTemplate->param(GENERATE => $form);
    }
    else
    {
        $buttonTemplate->param(SUBMIT => $submit{cookie('language')});
    }
    #------The form template--------------------
    $formTemplate->param(ID => 'forms-'. $form . '-form');
    $formTemplate->param(CLASS => 'forms-'. $form . '-form');
    $formTemplate->param(METHOD => $method);
    $formTemplate->param(ACTION => $action);
    $formTemplate->param(ENCTYPE => $enctype);
    $formTemplate->param(FORM => $form);
    $formTemplate->param(FORMDATA => $formData);
    $formTemplate->param(FORMBUTTON => $buttonTemplate->output());

    $cmd = "SELECT * FROM meta_data_tables WHERE table_name = ?";
    $sth = $dbh->prepare($cmd);
    $sth->execute($form);
    my $row = $sth->fetchrow_hashref();

    $formTemplate->param(TABLENAME => $row->{'label_' . cookie('language')});
    #------The Table template---------------------------
    $tableTemplate->param(TABLENAME => $row->{'label_' . cookie('language')});
    $tableTemplate->param(FORM => $form);
    $tableTemplate->param(ID => 'forms-'. $form . '-form');
    $tableTemplate->param(CLASS => 'forms-'. $form . '-form');

    my %response = ('content' => $formTemplate->output() . $tableTemplate->output());
    return \%response;
}
1;
__END__
