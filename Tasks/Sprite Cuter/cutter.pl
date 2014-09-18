#!/usr/bin/perl

use warnings;
use strict;
use GD;
use Switch;
use File::Basename;
use File::chdir;
use JSON::Parse 'parse_json';

#TODO
#1. Input should be the Root Game Directory - OK
#2. Read AS File-> get class names and directories of the images needed - OK
#3. For Each image - OK
####3.1 Get the sprite dimensions from the game.conf file - OK
####3.2 Run the "cut_image" script with the full path and dimensions - OK


#The Script should be placed in 'apps' folder

#Input - Name of game folder to work in.
my $gameRoot = $ARGV[0];
$CWD = $gameRoot;
my $asFileName = "Asset" . $gameRoot . "_base_hi.as";

#Edit for language cgange
my %languages =(
				0 => "_en",
				1 => "_bg",
				2 => "_ru",
				3 => "_es",
				4 => "_ro",
);
			
sub get_images{
	my($asFile) = @_;
	my %images;

	#game.conf to HASH
	local $/=undef;
	open FILE, "game.conf" or die "Couldn't open file: $!";
	my $gameConf = <FILE>;
	close FILE;
	my $json = parse_json($gameConf);
	

	open FILE, $asFile or die "Couldn't open file: $!"; 
	my $string = '';
	while (<FILE>) {
		my $line = $_;
		if(($line =~ /top/ || $line =~ /paytab/) && $line !~ /\/\/\//) {
		 $string .= $_;
			my $path = $line;
			my $class = $line;
			$path =~ /[Embed(source="*")]/;
			$class =~ /class_asset_*:Class/;
			$images{$class} = {	"path" => $path,
								"width" => $json{"layout"}{$class}[0],
								"height" => $json{"layout"}{$class}[1]			
			};
		}
	}
	close FILE;

	foreach my $key (keys %images) {
		cut_image($images{$key}{"path"},$images{$key}{"width"},$images{$key}{"height"});
	}
}

sub cut_image{
	my($img,$spriteWidth,$spriteHeight) = @_;

	my $spriteCounter = 0;
	my $maxCount = keys %languages;

	my $myImage = newFromPng GD::Image($img,1) || die "can't open $img";
	my ($width,$height) = $myImage->getBounds();
	my $wCount = $width/$spriteWidth;
	my $hCount = $height/$spriteHeight;

	my($filename, $path, $suffix) = fileparse($img, qr/\..../);

	for(my $i = 0; $i < $hCount; $i++) {
		for(my $j = 0; $j < $wCount; $j++) {
			my $index = $myImage->getPixel($j*$spriteWidth + $spriteWidth / 2, $i * $spriteHeight + $spriteHeight / 2);

			#full transparancy check
			my $transparent = 1;
			for(my $y = $i; $y < $spriteHeight; $y++){
				for(my $x = $j; $x < $spriteWidth; $x++){
					if($index >> 24 != 127) {
						$transparent = 0;
					}
				}
			}

			if(!$transparent) {
				my $newImage = newTrueColor GD::Image($spriteWidth,$spriteHeight);
				$newImage->saveAlpha(1);
				$newImage->alphaBlending(0);
				$newImage->copy($myImage,0,0,$j*$spriteWidth,$i*$spriteHeight,$spriteWidth,$spriteHeight);

				my $outputImage = $path . $filename . $languages->{$spriteCounter} . $suffix;

				$spriteCounter++;
		
				open(IMG,">$outputImage") || die "can't open $outputImage";
				binmode IMG;
				print IMG $newImage->png;
				close IMG;	
	
				if($spriteCounter >= $maxCount) {
					last;
				}	
			}			
		}

		if($spriteCounter >= $maxCount) {
			last;
		}
	}
}


