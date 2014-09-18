#!/usr/bin/perl
use CGI;
use strict;
use DBI;
use warnings;
use Encode;
use CGI::Session;
use Data::Dumper;
use CGI qw/:standard/;

my $retrieve_cookie = cookie('CGISESSID');
my $retrieve_username = cookie('username');
my $retrieve_language = cookie('language');

if($retrieve_cookie)
{
    my $session = CGI::Session->load($retrieve_cookie); 
    print $session->header(-type => 'application/json', -charset=>'utf-8');
    my $dbUser = "pg_user";
    my $host = "localhost";
    my $db = "office_devices";
    my $pw = "564564";
    my $conn = DBI->connect("DBI:Pg:dbname=".$db."; host=" . $host, $dbUser, $pw) || die "Could not connect to database";

    my $cgi = CGI->new;
    my $choice = $cgi->param("choice");
    my $offset = $cgi->param("offset");
    my $limit = $cgi->param("limit");

    if($choice eq "computers") 
    {
         my $cryteria = lc($cgi->param("cryteria"));
        #my $lscmd = "SELECT TC.translated_name FROM translated_columns as TC JOIN columns AS C on C.id = TC.column_id JOIN languages as L ON L.id = TC.language_id WHERE C.column_name = ? AND L.language = ?";
        #my $lrows = $conn->prepare($lscmd);
        #$lrows->execute("host_name",$lang);
        #my $lref = $lrows->fetchrow_hashref();
        #my $translated = decode_utf8( $lref->{'translated_name'} );
        my $col1 = $conn->quote_identifier("computer_name_".$retrieve_language);
        my $col2 = $conn->quote_identifier("network_name_".$retrieve_language);
        
        my $scmd = 
            "SELECT * , pc.id AS pcid
                FROM computers AS pc
                JOIN networks AS net
                ON pc.network_id = net.id
                WHERE lower(serial_num) <> ? 
                AND exists <> ? 
                AND (
                    lower(serial_num) LIKE ? 
                    OR lower($col1) LIKE ? 
                    OR lower($col2) LIKE ?
                    ) 
                
            ORDER BY pc.date_updated DESC LIMIT ? ";
    
        my $response = '{ "status" : "OK", "type": "computers", "data" :[';
        my $comma = 0;

            my @headers; 
            my $langref;
            my $langscmd = "SELECT * FROM meta_data_inputs WHERE column_name = ?";
            my $langrows = $conn->prepare($langscmd);

            $langrows->execute('serial_num');
            $langref = $langrows->fetchrow_hashref();

            push(@headers, decode_utf8($langref->{'label_' . $retrieve_language}));

            $langrows->execute('computer_name_'.$retrieve_language);
            $langref = $langrows->fetchrow_hashref();
            push(@headers, decode_utf8($langref->{'label_' . $retrieve_language}));

            $langrows->execute('network_name_'.$retrieve_language);
            $langref = $langrows->fetchrow_hashref();
            push(@headers, decode_utf8($langref->{'label_' . $retrieve_language}));
            my $rows = $conn->prepare($scmd);
        $rows->execute('none','f','%' . $cryteria . '%','%' . $cryteria . '%','%' . $cryteria . '%',100) || die "couldnt fetch computers\n";    


        while(my $ref = $rows->fetchrow_hashref()) 
        {
            if($comma) 
            {
                $response .= ",";
            }   
            my $serial = decode_utf8( $ref->{'serial_num'} );
            my $name = decode_utf8( $ref->{'computer_name_'. $retrieve_language} );
            my $network = decode_utf8( $ref->{'network_name_'. $retrieve_language} );
            my $id = $ref->{'pcid'};

            $response .= '{"id" : "' . $id . '", "' . $headers[0] . '":' . "\"$serial\"," . '"' . $headers[1] . '":' . "\"$name\"," . '"' . $headers[2] . '":' . "\"$network\"}";
            $comma = 1; 
        }
        $response .= ']}';
        print $response;
    }


#     elsif($choice eq "networks") 
#     {
#         my $lscmd = "SELECT TC.translated_name FROM translated_columns as TC JOIN columns AS C on C.id = TC.column_id JOIN languages as L ON L.id = TC.language_id WHERE C.column_name = ? AND L.language = ?";
#         my $lrows = $conn->prepare($lscmd);
#         $lrows->execute("name",$lang);
#         my $lref = $lrows->fetchrow_hashref();
#         my $translated = decode_utf8( $lref->{'translated_name'} );

#         my $scmd = "SELECT name FROM networks";
#         my $rows = $conn->prepare($scmd);
#         $rows->execute() || die "couldnt fetch networks\n"; 
#         my $response = '{"data":[';
#         my $comma = 0;

#         while(my $ref = $rows->fetchrow_hashref()) 
#         {
#             if($comma)
#              {
#                 $response .= ",";
#             }
#             my $name = decode_utf8( $ref->{'name'} ); 
#             $response .= "{\"$translated\":" . "\"$name\"}";
#             $comma = 1; 
#         }

#         $response .= "]}";
#         print $response;
#     }

#     elsif($choice eq "models") 
#     {
#         my $lscmd = "SELECT TC.translated_name FROM translated_columns as TC JOIN columns AS C on C.id = TC.column_id JOIN languages as L ON L.id = TC.language_id WHERE C.column_name = ? AND L.language = ?";
#         my $lrows = $conn->prepare($lscmd);
#         $lrows->execute("model",$lang);
#         my $lref = $lrows->fetchrow_hashref();
#         my $translatedm = decode_utf8( $lref->{'translated_name'} );
#         $lrows->execute("type",$lang);
#         $lref = $lrows->fetchrow_hashref();
#         my $translatedt = decode_utf8( $lref->{'translated_name'} );

#         my $scmd = "SELECT models.model,types.type FROM models JOIN types ON models.type_id = types.id";
#         my $rows = $conn->prepare($scmd);
#         $rows->execute() || die "couldnt fetch types or models\n";  
#         my $response = '{"data":[';
#         my $comma = 0;

#         while(my $ref = $rows->fetchrow_hashref()) 
#         {
#             if($comma) 
#             {
#                 $response .= ",";
#             }
#             my $type = decode_utf8( $ref->{'type'} );
#             my $model = decode_utf8( $ref->{'model'} ); 
#             $response .= "{\"$translatedm\":" . "\"$model\"," . "\"$translatedt\":" . "\"$type\"}";
#             $comma = 1; 
#         }

#         $response .= "]}";
#         print $response;
#     }

#     elsif($choice eq "types") 
#     {
#         my $lscmd = "SELECT TC.translated_name FROM translated_columns as TC JOIN columns AS C on C.id = TC.column_id JOIN languages as L ON L.id = TC.language_id WHERE C.column_name = ? AND L.language = ?";
#         my $lrows = $conn->prepare($lscmd);
#         $lrows->execute("type",$lang);
#         my $lref = $lrows->fetchrow_hashref();
#         my $translated = decode_utf8( $lref->{'translated_name'} );

#         my $scmd = "SELECT type FROM types";
#         my $rows = $conn->prepare($scmd);
#         $rows->execute() || die "couldnt fetch types\n";    
#         my $response = '{"data":[';
#         my $comma = 0;

#         while(my $ref = $rows->fetchrow_hashref())
#          {
#             if($comma) 
#             {
#                 $response .= ",";
#             }
#             my $type = decode_utf8( $ref->{'type'} ); 
#             $response .= "{\"$translated\":" . "\"$type\"}";
#             $comma = 1; 
#         }

#         $response .= "]}";
#         print $response;
#     }

#     elsif($choice eq "network-devices") 
#     {
#         my $lscmd = "SELECT TC.translated_name FROM translated_columns as TC JOIN columns AS C on C.id = TC.column_id JOIN languages as L ON L.id = TC.language_id WHERE C.column_name = ? AND L.language = ?";
#         my $lrows = $conn->prepare($lscmd);
#         $lrows->execute("model",$lang);
#         my $lref = $lrows->fetchrow_hashref();
#         my $translatedm = decode_utf8( $lref->{'translated_name'} );
#         $lrows->execute("warranty",$lang);
#         $lref = $lrows->fetchrow_hashref();
#         my $translatedw = decode_utf8( $lref->{'translated_name'} );

#         my $scmd = "SELECT models.model,network_devices.warranty FROM models JOIN network_devices ON network_devices.model_id = models.id";
#         my $rows = $conn->prepare($scmd);
#         $rows->execute() || die "couldnt fetch network_devices or models\n";
#         my $response = '{"data":[';
#         my $comma = 0;

#         while(my $ref = $rows->fetchrow_hashref()) 
#         {
#             if($comma)
#             {
#                 $response .= ",";
#             }
#             my $warranty = decode_utf8( $ref->{'warranty'} );
#             my $model = decode_utf8( $ref->{'model'} ); 
#             $response .= "{\"$translatedm\":" . "\"$model\"," . "\"$translatedw\":" . "\"$warranty\"}";
#             $comma = 1; 
#         }

#         $response .= "]}";
#         print $response;
#     }

#     elsif($choice eq "computer-parts") 
#     {
#         my $lscmd = "SELECT TC.translated_name FROM translated_columns as TC JOIN columns AS C on C.id = TC.column_id JOIN languages as L ON L.id = TC.language_id WHERE C.column_name = ? AND L.language = ?";
#         my $lrows = $conn->prepare($lscmd);
#         $lrows->execute("model",$lang);
#         my $lref = $lrows->fetchrow_hashref();
#         my $translatedm = decode_utf8( $lref->{'translated_name'} );
#         $lrows->execute("warranty",$lang);
#         $lref = $lrows->fetchrow_hashref();
#         my $translatedw = decode_utf8( $lref->{'translated_name'} );
            
#         my $scmd = "SELECT models.model,hardware_parts.warranty FROM models JOIN hardware_parts ON hardware_parts.model_id = models.id";
#         my $rows = $conn->prepare($scmd);
#         $rows->execute() || die "couldnt fetch hardware_parts or models\n"; 
#         my $response = '{"data":[';
#         my $comma = 0;

#         while(my $ref = $rows->fetchrow_hashref()) 
#         {
#             if($comma) 
#             {
#                 $response .= ",";
#             }
#             my $warranty = decode_utf8( $ref->{'warranty'} );
#             my $model = decode_utf8( $ref->{'model'} ); 
#             $response .= "{\"$translatedm\":" . "\"$model\"," . "\"$translatedw\":" . "\"$warranty\"}";
#             $comma = 1; 
#         }

#         $response .= "]}";
#         print $response;
#     }
}
else
{
    print "Content-type: application/json\n\n";
    my $response = '{ "status" : "OUT" }';
    print $response;

}
