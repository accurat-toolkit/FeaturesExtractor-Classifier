#!/usr/bin/perl

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

use strict;
use warnings;
use utf8;
use File::Find;
use lib './Subs/';
use AllInterLinksOverlapSub;
use AllOutLinksOverlapSub;
use DocLengthWithoutTranslationSub;
use ImageLinksFilenameOverlapSub;
use ImageLinksOverlapSub;
use ImageLinksWordsOverlapSub;
use URLLevelAndCharacterOverlapSub;

my $temp = "@ARGV";

my ($source, $target, $outputPath, $metadataFile);
if (($temp =~ m/--outputFolder/) && ($temp =~ m/--source/) && ($temp =~ m/--target/) && ($temp =~ m/--metadata/)) {
}
else
{ 
  print "-------------------------------------------------------------------------------------------------------\n";
  print "To run this script, please add the source language and target language after the name of the script:\n\n";
  print "     \"perl CalculateIndependentFeatures.pl --source [sourceLang] --target [targetLang] --metadata\n";
  print "     [metadataFile] --outputFolder [outputFolder]\"\n\n";
  print "An example of its use is:\n\n";
  print "     \"perl CalculateIndependentFeatures.pl --source HR --target EN --metadata C:\\ACCURAT\\HR-EN-pairs.txt\n";
  print "     --outputFolder C:\\ACCURAT\\Output\"\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  exit;
}

for (my $i=0; $i < scalar @ARGV; $i = $i+2) {
	if ($ARGV[$i] eq "--source") {
		$source = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--target") {
		$target = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--outputFolder") {
		$outputPath = $ARGV[$i+1];
		if ($outputPath =~ m/\/$/) {
		}
		else {
			$outputPath .= "/";
		}
	}
	elsif ($ARGV[$i] eq "--metadata") {
		$metadataFile = $ARGV[$i+1];
	}
	else {
		print "Format $ARGV[$i] is not recognized. Please correct the format and restart the tool.\n";
		exit();
	}
}

print "- Calculating All Inter Links Overlap ...\n";
AllInterLinksOverlapSub "$source\t$target\t$metadataFile\t$outputPath";

print "- Calculating All Out Links Overlap ...\n";
AllOutLinksOverlapSub "$source\t$target\t$metadataFile\t$outputPath";

print "- Calculating Doc Length without Translation ...\n";
DocLengthWithoutTranslationSub "$source\t$target\t$metadataFile\t$outputPath";

print "- Calculating Image Links Filename Overlap Sub ...\n";
ImageLinksFilenameOverlapSub "$source\t$target\t$metadataFile\t$outputPath";

print "- Calculating Image Links Overlap ...\n";
ImageLinksOverlapSub "$source\t$target\t$metadataFile\t$outputPath";

print "- Calculating Image Links Words Overlap ...\n";
ImageLinksWordsOverlapSub "$source\t$target\t$metadataFile\t$outputPath";

print "- Calculating URL Level And Character Overlap ...\n";
URLLevelAndCharacterOverlapSub "$source\t$target\t$metadataFile\t$outputPath";

print "\nIndependent features were successfully extracted!\n";
