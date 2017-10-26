#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;

my ($sourcedata, $output, $targetFile, $sourceFile, @words);
my (%sourceWords, %targetWords, %allWords);

sub WordOverlapCosineSimilaritySub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	my $sourcedata = $args[2];
	my $outputPath = $args[3];

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	$output = $outputPath . "$source-$target-output/$source-$target-WordOverlap-CosineSimilarity.txt";

	#open source data and output
	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tdocName1\tdocName2\tNumberOfUniqueWords1\tNumberOfUniqueWords2\tCosineSimilarity\n";

	while (<INPUT>) {

		%allWords = ();

		my $sentence = $_;
		#chomp ($sentence);
		#print "$sentence\n";
		
		if ($sentence =~ /DocName_1/) {
			#ignore the first sentence
		}
		else {
			my @data = split(/[\t]/, $_);

			my $comparabilityLevel = "null";
			my $docName1 = $data[0];
			my $sourceLC = lc $source;
			my $targetLC = lc $target;


			my $docName2 = $data[4];

			%sourceWords = ();
			%targetWords = ();

			#print "$docName1-----------$docName2\n";

			print OUTPUT "$comparabilityLevel\t$docName1\t$docName2\t"; 

			#count length of document 1
			my $translatedSourceFile = $data[1];

			if (-e $translatedSourceFile) {
				open INPUTDOC1, $translatedSourceFile or die "Couldn't open file $translatedSourceFile: $!\n";

				while (<INPUTDOC1>) {
					my @sourceWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					my $size = scalar @sourceWordsTemp;
				
					for (my $i = 0; $i < $size; $i++) {
						#print "$sourceWordsTemp[$i]\n";
						$sourceWords{$sourceWordsTemp[$i]} = '1';
						$allWords{$sourceWordsTemp[$i]} = '1';

						#$sourceWords{$sourceWordsTemp[$i]} = '1';
						#print "UP here: ". keys (%sourceWords) . "\n";
					}
				}
				close INPUTDOC1;
				print OUTPUT keys (%sourceWords) . "\t";
			}
			else {
				print OUTPUT "null\t";
			}

			#count length of document 2
			my $targetFile = $data[5];

			if (-e $targetFile) {
				open INPUTDOC2, $targetFile; # or die "Couldn't open file $targetFile: $!\n";

				while (<INPUTDOC2>) {
					my @targetWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					my $size = scalar @targetWordsTemp;
					for (my $i = 0; $i < $size; $i++) {
						#print "$targetWordsTemp[$i]\n";
						my $stemmedWord = porter $targetWordsTemp[$i];
						if (exists $targetWords{$stemmedWord}) {
						}
						else {
							$targetWords{$stemmedWord} = 1;
						}

						$targetWords{$targetWordsTemp[$i]} = '1';
						$allWords{$targetWordsTemp[$i]} = '1';
					}
				}
				close INPUTDOC2;

				print OUTPUT keys (%targetWords) . "\t";

			}
			else {
				print OUTPUT "null\t";
			}

			my $overlap = 0;
			my $sigmaFreqMultiple = 0;
			my $denominator = 0;

			my $sigmaSourceFreqSquare =0;
			my $sigmaTargetFreqSquare = 0;

			if ((-e $targetFile) && (-e $translatedSourceFile)) {
				for my $key (keys %allWords) {
					my $sourceFreq = 0;
					if (exists $sourceWords{$key}) {
						$sourceFreq++;
					}
					$sigmaSourceFreqSquare += $sourceFreq*$sourceFreq;

					my $targetFreq = 0;
					if (exists $targetWords{$key}) {
						$targetFreq++;
					}
					$sigmaFreqMultiple += $sourceFreq * $targetFreq;
					$sigmaTargetFreqSquare += $targetFreq*$targetFreq;
				}

				$denominator = sqrt ($sigmaSourceFreqSquare*$sigmaTargetFreqSquare);

				if ($denominator != 0) {
					my $cosine = $sigmaFreqMultiple/$denominator;

					print OUTPUT "$cosine";
				}
				else {
					print OUTPUT "null";
				}
			}
			else {
				print OUTPUT "null";
			}
			print OUTPUT "\n";
		}
	}
}
1;