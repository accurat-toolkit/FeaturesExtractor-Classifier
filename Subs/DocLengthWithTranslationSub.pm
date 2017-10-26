#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;

my ($sourcedata, $output, @words);

sub DocLengthWithTranslationSub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	my $sourcedata = $args[2];
	my $outputPath = $args[3];

	if (-d $outputPath) {
	}
	else {
		mkdir $outputPath;
	}

	if (-d $outputPath . "$source-$target-output/") {
	}
	else {
		mkdir $outputPath . "$source-$target-output/";
	}

	$output = $outputPath . "$source-$target-output/$source-$target-DocLengthWithTranslation.txt";

	#open source data and output
	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tDocLengthWithTrans_1\tDocLengthWithTrans_2\tAbsoluteDifference\tRelativeDifference\n";

	while (<INPUT>) {

		my $sentence = $_;
		
		if ($sentence =~ /DocName_1/) {
			#ignore the first sentence
		}
		else {
			my @data = split(/[\t]/, $_);

			my $comparabilityLevel = "null";
			my $initDocName1 = $data[0];

			my $sourceLC = lc $source;
			my $targetLC = lc $target;

			my $initDocName2 = $data[4];

			#print "$docName1-----------$docName2\t";

			print OUTPUT "$comparabilityLevel\t$initDocName1\t$initDocName2\t"; 

			#count length of document 1
			my $translatedSourceFile =  $data[1];

			my ($numberOfWordsInDoc1, $numberOfWordsInDoc2);

			if (-e $translatedSourceFile) {
				open INPUTDOC1, $translatedSourceFile or die "Couldn't open file $translatedSourceFile: $!\n";

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
			my $targetFile = $data[5];

			if (-e $targetFile) {
				open INPUTDOC2, $targetFile; # or die "Couldn't open file $targetFile: $!\n";

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

			if ((-e $translatedSourceFile) && (-e $targetFile)) {
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
				if ($numberOfWordsInDoc2 == 0) {
					$relDiff = "null";
				}
				else {
					$relDiff = $absDiff/$numberOfWordsInDoc2;
				}
				print OUTPUT "$relDiff";
			}
			else  {
				print OUTPUT "null\tnull";
			}
			print OUTPUT "\n";
		}
	}
}
1;