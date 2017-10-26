#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;

my ($sourcedata, $output, $enFile, $elFile, @words);

sub DocLengthWithoutTranslationSub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $sourcedata = $args[2];
	my $outputPath = $args[3];

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	$output = $outputPath . "$source-$target-output/$source-$target-DocLengthWithoutTranslation.txt";

	#open source data and output
	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tDocLengthWithoutTrans_1\tDocLengthWithoutTrans_2\tAbsoluteDifference\tRelativeDifference\n";
	while (<INPUT>) {

		my $sentence = $_;
		#chomp ($sentence);
		#print "$sentence\n";
		
		if (/DocName_1/) {
			#ignore the first sentence
		}
		else {
			my @data = split(/[\t]/, $_);

			my $comparabilityLevel = "null";
			my $docName1 = $data[0];

			my $docName2 = $data[4];

			print OUTPUT "$comparabilityLevel\t$docName1\t$docName2\t"; 

			#count length of document 1
			my $sourceFile = $docName1;
			my ($numberOfWordsInDoc1, $numberOfWordsInDoc2);

			if (-e $sourceFile) {
				open INPUTDOC1, $sourceFile or die "Couldn't open file $sourceFile: $!\n";

				$numberOfWordsInDoc1 = 0;
				while (<INPUTDOC1>) {
					@words = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					$numberOfWordsInDoc1 += @words;
				}
				close INPUTDOC1;

				print OUTPUT "$numberOfWordsInDoc1\t";
			}
			else {
				print OUTPUT "null\t";
			}
			#count length of document 2
			my $targetFile = $docName2;
			if (-e $targetFile) {
				open INPUTDOC2, $targetFile; # or die "Couldn't open file $enFile: $!\n";

				$numberOfWordsInDoc2 = 0;
				while (<INPUTDOC2>) {
					@words = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					$numberOfWordsInDoc2 += @words;
				}

				close INPUTDOC2;

				print OUTPUT "$numberOfWordsInDoc2\t";
			}
			else {
				print OUTPUT "null\t";
			}
			if ((-e $targetFile) && (-e $sourceFile)) {

				my ($absDiff, $relDiff);

				#count absoluteDifference
				if ($numberOfWordsInDoc1 > $numberOfWordsInDoc2) {
					$absDiff = $numberOfWordsInDoc1 - $numberOfWordsInDoc2;
				}
				else {
					$absDiff = $numberOfWordsInDoc2 - $numberOfWordsInDoc1;
				}
				print OUTPUT "$absDiff\t";

				#count relativeDifference
				$relDiff = $absDiff/$numberOfWordsInDoc2;
				print OUTPUT "$relDiff";
			}
			else {
				print OUTPUT "null\tnull";
			}
			print OUTPUT "\n";
		}
	}
}
1;