#!/usr/bin/perl

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

use strict;
use warnings;

my $temp = "@ARGV";
if (scalar @ARGV < 18) { 
  print "Missing parameter. Please run the tool based on the guideline below.\n\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  print "To run this script, please use the following arguments:\n\n";
  print "     \"perl CreateCombinations.pl --source [sourceLang] --target [targetLang] --sourceFile [sourceFile]\n";
  print "     --targetFile [targetFile] --sourcetranslation [sourceTranslationFile] --sourcehtml [sourceHTMLFile]\n";
  print "     --targettranslation [targetTranslationFile] --targethtml [targetHTMLFile] --metadata [outputmetadataFile]\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  exit;
}

my ($sourceFile, $targetFile, $metadataFile, $sourceTranslationFile, $targetTranslationFile, $sourceHTMLFile, $targetHTMLFile, $sourceLang, $targetLang);
for (my $i=0; $i < scalar @ARGV; $i = $i+2) {
	if ($ARGV[$i] eq "--source") {
		$sourceLang = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--target") {
		$targetLang = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--sourceFile") {
		$sourceFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--targetFile") {
		$targetFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--metadata") {
		$metadataFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--sourcetranslation") {
		$sourceTranslationFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--targettranslation") {
		$targetTranslationFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--sourcehtml") {
		$sourceHTMLFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--targethtml") {
		$targetHTMLFile = $ARGV[$i+1];
	}
	else {
		print "53: Format $ARGV[$i] is not recognized. Please correct the format and restart the tool.\n";
		exit();
	}
}

my @sourceList = ();
my @targetList = ();
my @sourceTranslations = ();
my @targetTranslations = ();
my @sourceHTML = ();
my @targetHTML = ();
my %combinations = ();

#load source file list
open INPUT, "<:utf8", $sourceFile or die "Cannot open file $sourceFile.\n";
while (<INPUT>) {
	chomp($_);
	push(@sourceList, $_);
}
close INPUT;

#load target file list
open INPUT, "<:utf8", $targetFile or die "Cannot open file $targetFile.\n";
while (<INPUT>) {
	chomp($_);
	push(@targetList, $_);
}
close INPUT;

#load source translations
open INPUT, "<:utf8", $sourceTranslationFile or die "Cannot open file $sourceTranslationFile.\n";
while (<INPUT>) {
	chomp($_);
	push(@sourceTranslations, $_);
}
close INPUT;

#load target translations
open INPUT, "<:utf8", $targetTranslationFile or die "Cannot open file $targetTranslationFile.\n";
while (<INPUT>) {
	chomp($_);
	push(@targetTranslations, $_);
}
close INPUT;

#load source html
open INPUT, "<:utf8", $sourceHTMLFile or die "Cannot open file $sourceHTMLFile.\n";
while (<INPUT>) {
	chomp($_);
	push(@sourceHTML, $_);
}
close INPUT;

#load target html
open INPUT, "<:utf8", $targetHTMLFile or die "Cannot open file $targetHTMLFile.\n";
while (<INPUT>) {
	chomp($_);
	push(@targetHTML, $_);
}
close INPUT;

open OUTPUT, ">:utf8", $metadataFile or die "Cannot open file $metadataFile.\n";

for (my $i = 0; $i < scalar @sourceList; $i++) {
	my $sourceFile = $sourceList[$i];
	for (my $j = 0; $j < scalar @targetList; $j++) {
		my $targetFile = $targetList[$j];
		if (exists $combinations{"$sourceFile\t$targetFile"}) {
		}
		else {
			$combinations{"$sourceFile\t$targetFile"} = 1;

			my $translatedSource = $sourceTranslations[$i];
			my $translatedTarget = "";
			if ($targetLang eq "EN") {
				$translatedTarget = $targetFile;
			}
			else {
				$translatedTarget = $targetTranslations[$j];
			}
			#if the target language is EN, use the original file as the translation
			my $htmlSource = $sourceHTML[$i];
			my $htmlTarget = $targetHTML[$j];
			print OUTPUT "$sourceFile\t$translatedSource\t$htmlSource\t\t$targetFile\t$translatedTarget\t$htmlTarget\t\n";
		}
	}
}
close OUTPUT;