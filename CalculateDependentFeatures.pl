#!/usr/bin/perl

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

use strict;
use warnings;
use utf8;
use File::Find;
use lib './Subs/';
use IndexAllFilesSub;
use BiGramFreqOverlapStemmedCosineSimilaritySub;
use DocLengthWithTranslationSub;
use TermFreqOverlapCosineSimilaritySub;
use TermFreqOverlapStemmedCosineSimilaritySub;
use TFIDFOverlapStemmedCosineSimilaritySub;
use TriGramFreqOverlapStemmedCosineSimilaritySub;
use WordOverlapSub;
use WordOverlapCosineSimilaritySub;
use WordOverlapStemmedSub;
use WordOverlapStemmedCosineSimilaritySub;

my ($source, $target, $inputPath, $outputPath, $metadataFile);

my $temp = "@ARGV";

if (($temp =~ m/--outputFolder/) && ($temp =~ m/--source/) && ($temp =~ m/--target/) && ($temp =~ m/--metadata/)) {
}
else
{ 
  print "-------------------------------------------------------------------------------------------------------\n";
  print "To run this script, please add the source language and target language after the name of the script:\n\n";
  print "     \"perl CalculateDependentFeatures.pl --source [sourceLang] --target [targetLang] --metadata\n";
  print "     [metadataFile] --outputFolder [outputFolder]\"\n\n";
  print "An example of its use is:\n\n";
  print "     \"perl CalculateDependentFeatures.pl --source HR --target EN --metadata C:\\ACCURAT\\HR-EN-pairs.txt\n";
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

print "\n\nIndexing all files ...\n";
IndexAllFilesSub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Bi-Gram Frequency Overlap (Stemmed) - CosineSimilarity ...\n";
BiGramFreqOverlapStemmedCosineSimilaritySub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Doc Length with Translation ...\n";
DocLengthWithTranslationSub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Term Frequency Overlap - Cosine Similarity ...\n";
TermFreqOverlapCosineSimilaritySub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Term Frequency Overlap (Stemmed) - Cosine Similarity  ...\n";
TermFreqOverlapStemmedCosineSimilaritySub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating TF-IDF Overlap (Stemmed) - Cosine Similarity ...\n";
TFIDFOverlapStemmedCosineSimilaritySub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Tri-Gram Frequency Overlap Stemmed - Cosine Similarity ...\n";
TriGramFreqOverlapStemmedCosineSimilaritySub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Word Overlap ...\n";
WordOverlapSub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Word Overlap -Cosine Similarity ...\n";
WordOverlapCosineSimilaritySub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Word Overlap (Stemmed) ...\n";
WordOverlapStemmedSub "$source\t$target\t$metadataFile\t$outputPath";

print "Calculating Word Overlap (Stemmed) - Cosine Similarity ...\n";
WordOverlapStemmedCosineSimilaritySub "$source\t$target\t$metadataFile\t$outputPath";

print "\nFinished!\n";