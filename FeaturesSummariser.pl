#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

use strict;
use warnings;

my $temp = "@ARGV";

my ($source, $target, $outputPath);
my $comparabilityFile = "";
if (($temp =~ m/--outputFolder/) && ($temp =~ m/--source/) && ($temp =~ m/--target/)) {
}
else
{ 
  print "-------------------------------------------------------------------------------------------------------\n";
  print "To run this script, please add the source language and target language after the name of the script:\n\n";
  print "     \"perl FeaturesSummariser.pl --source [sourceLang] --target [targetLang] --outputFolder [outputFolder]\n";
  print "      (--comparabilityFile [comparabilityFile])\"\n\n";
  print "An example of its use is:\n\n";
  print "     \"perl FeaturesSummariser.pl --source HR --target EN --outputFolder C:\\ACCURAT\\Output\n";
  print "     (--comparabilityFile C:\\ACCURAT\\ComparabilityLevel.txt)\"\n";
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
	elsif ($ARGV[$i] eq "--comparabilityFile") {
		$comparabilityFile = $ARGV[$i+1];
	}
	else {
		print "Format $ARGV[$i] is not recognized. Please correct the format and restart the tool.\n";
		exit();
	}
}

$outputPath .= "$source-$target-output/";

my $summary = $outputPath . "$source-$target-Summary.txt";
my $file1 = "$source-$target-AllInterLinksOverlap.txt";
my $file2 = "$source-$target-AllOutLinksOverlap.txt";
my $file3 = "$source-$target-ImageLinksFilenameOverlap.txt";
my $file4 = "$source-$target-ImageLinksWordOverlap.txt";
my $file5 = "$source-$target-BiGramFreqOverlap-Stemmed-CosineSimilarity.txt";
my $file6 = "$source-$target-DocLengthWithoutTranslation.txt";
my $file7 = "$source-$target-DocLengthWithTranslation.txt";
my $file8 = "$source-$target-TermFreqOverlap-CosineSimilarity.txt";
my $file9 = "$source-$target-TermFreqOverlap-Stemmed-CosineSimilarity.txt";
my $file10 = "$source-$target-TFIDFOverlap-Stemmed-CosineSimilarity.txt";
my $file11 = "$source-$target-TriGramFreqOverlap-Stemmed-CosineSimilarity.txt";
my $file12 = "$source-$target-URLLevelAndCharacterOverlap.txt";
my $file13 = "$source-$target-WordOverlap.txt";
my $file14 = "$source-$target-WordOverlap-CosineSimilarity.txt";
my $file15 = "$source-$target-WordOverlap-stemmed.txt";
my $file16 = "$source-$target-WordOverlap-CosineSimilarity-stemmed.txt";

my @featureFiles = ($file1, $file2, $file3, $file4, $file5, $file6, $file7, $file8, $file9, $file10,
$file11, $file12, $file13, $file14, $file15, $file16);

open OUTPUT, ">:utf8", $summary or die "Cannot open file $summary: $!\n";
my %featureValues = ();
my %comparabilityLevel = ();
my @filesList = ();

my $lcsource = lc $source;
my $lctarget = lc $target;
my $i = 0;

foreach my $file (@featureFiles) {
	my $featuresFile = $outputPath . $file;
	if (-e $featuresFile) {
		open INPUT, $featuresFile or die "Cannot open file $featuresFile: $!\n";
		$i++;
		my $total = 0;
		while (<INPUT>) {
			chomp($_);
			my $sentence = $_;
			my @data = ();
			my $value = "";

			if ($sentence =~ /Comparability Level/) {
				@data = split("\t", $sentence);
				$total = scalar @data;
				#print "51: $file: $total\n"; 
			}
			else {
				@data = split("\t", $sentence);
				if ((scalar @data) < $total) {
					$value = "null";
				}
				else {
					$value = $data[$total-1];

					if ($value eq "") {
						$value = "null";
					}
				}
				my $compLevel = $data[0];
				my $docName1 = $data[1];
				if ($docName1 =~ /\.html/) {
					$docName1 =~ s/\.html/.txt/i;
				}
				elsif ($docName1 =~ /_$lcsource\_$lctarget.txt/) {
					$docName1 =~ s/_$lcsource\_$lctarget.txt/_$lcsource.txt/i;
				}
				elsif ($docName1 =~ /_$lcsource\_en.txt/) {
					$docName1 =~ s/_$lcsource\_en.txt/_$lcsource.txt/i;
				}
				elsif ($docName1 =~ /_$lcsource\_$lctarget\_/) {
					$docName1 =~ s/_$lcsource\_$lctarget\_/_$lcsource\_/i;
				}
				elsif ($docName1 =~ /_$lcsource\_en\_/) {
					$docName1 =~ s/_$lcsource\_en\_/_$lcsource\_/i;
				}

				my $docName2 = $data[2];

				if ($docName2 =~ /\.html/) {
					$docName2 =~ s/\.html/.txt/i;
				}
				elsif ($docName2 =~ /_$lctarget\_en.txt/) {
					$docName2 =~ s/_$lctarget\_en.txt/_$lctarget.txt/i;
				}

				my $id = $compLevel . "\t". $docName1 . "\t" . $docName2;

				if (exists $featureValues{$id}) {
					$featureValues{$id} .= "\t$value";
				}
				else {
					$featureValues{$id} = "$value";
					$comparabilityLevel{$id} = $compLevel;
					push(@filesList, $id);
				}
			}
		}
		close INPUT;
	}
	else {
		print "File $featuresFile does not exist.\n";
		foreach my $id (@filesList) {
			if (exists $featureValues{$id}) {
				$featureValues{$id} .= "\tnull";
			}
		}
	}
}

#if comparability level exists (for example, for available (and manually judged) comparable corpora), get the comparability level
#and overwrite the level.

if ($comparabilityFile ne "") {
	open INPUT, $comparabilityFile or die "Could not open file $comparabilityFile: $!\n";

	while (<INPUT>) {
		chomp($_);
		my @data = split(/\t/, $_);
		my $compLevel = $data[0];
		my $docName1 = $data[1];
		my $docName2 = $data[2];

		my $id = "null\t". $docName1 . "\t" . $docName2;
		$comparabilityLevel{$id} = $compLevel;
	}
	close INPUT;
}
print OUTPUT "SourceFile\tTargetFile\tComparability Level\t$file1\t$file2\t$file3\t$file4\t$file5\t$file6\t$file7\t$file8\t" .
 "$file9\t$file10\t$file11\t$file12\t$file13\t$file14\t$file15\t$file16\n";

foreach my $id (@filesList) {
	my @data = split("\t", $id);
	my $docName1 = $data[1];
	my $docName2 = $data[2];

	print OUTPUT $docName1 . "\t" . $docName2 . "\t" . $comparabilityLevel{$id} . "\t". $featureValues{$id}. "\n";
}
close OUTPUT;
print "Finished: Your summary can be found in $summary.\n"; 