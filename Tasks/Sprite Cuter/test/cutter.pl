#!/usr/bin/perl

use warnings;
use strict;
use GD;

my $img = $ARGV[0];
my $spriteHeight = $ARGV[2];
my $spriteWidth = $ARGV[1];

my $myImage = newFromPng GD::Image($img);

my ($width,$height) = $myImage->getBounds();
my $spriteCount = ($width*$height)/($spriteWidth*$spriteHeight);



for(my $i = 0; $i < $spriteCount; $i++) {
	my $newImage = new GD::Image($spriteWidth,$spriteHeight);
	$newImage->saveAlpha(1);
	$newImage->alphaBlending(0);
	$newImage->copy($myImage,0,0,$i*$spriteWidth,0,$spriteWidth,$spriteHeight);
	my $black = $newImage->colorClosest(0,0,0); # find white
	$newImage->transparent($black);
	open(IMG,">$i.png") or die "cant open";
	binmode IMG;
	print IMG $newImage->png;
	close IMG;
}











