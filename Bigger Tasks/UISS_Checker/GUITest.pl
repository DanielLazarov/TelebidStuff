use Tk;

$main = MainWindow->new();

$labelEGN = $main->Label(-text=>"EGN:");
$labelFN = $main->Label(-text=>"FN:");
$labelMail = $main->Label(-text=>"eMail:");



$entryEGN = $main->Entry();
$entryFN = $main->Entry();
$entryMail = $main->Entry();

$entryEGN->bind("<Return>", \&handle_return );
$entryFN->bind("<Return>", \&handle_return );
$entryMail->bind("<Return>", \&handle_return );

$entryMail->pack(-side=>"bottom");
$labelMail->pack(-side=>"bottom");
$entryFN->pack(-side=>"bottom");
$labelFN->pack(-side=>"bottom");
$entryEGN->pack(-side=>"bottom");
$labelEGN->pack(-side=>"bottom");

MainLoop();

sub handle_return {
    $EGN = $entryEGN->get();
	$FN = $entryFN->get();
	$Mail = $entryMail->get();
    print "EGN: $EGN\n";
	print "FN: $FN\n";
	print "eMail: $Mail\n";
    exit;
}
