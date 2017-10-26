#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;
use porter;

my ($sourcedata, $output, $targetFile, $sourceFile, @words);
my (%sourceWords, %targetWords, %allWords);

sub TriGramFreqOverlapStemmedCosineSimilaritySub {

	my $N = 3; #to calculate trigram

	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	my $sourcedata = $args[2];
	my $outputPath = $args[3];

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	$output = $outputPath . "$source-$target-output/$source-$target-TriGramFreqOverlap-Stemmed-CosineSimilarity.txt";

	#open source data and output
	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tNumberOfUniqueTriGrams1\tNumberOfUniqueTriGrams2\tCosineSimilarity-NormalisedTriGramFreq\n";
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
					my @sentenceTemp = split(/[?!\.]+/, $_);
					my $sentenceSize = scalar @sentenceTemp;

					for (my $i=0; $i < $sentenceSize; $i++) {

						$_ = $sentenceTemp[$i];
						chomp($_);
						s/^\s+//;
						s/\s+$//;

						my @sourceWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
						my $size = scalar @sourceWordsTemp;
					
						for (my $j = 0; $j < ($size-$N+1); $j++) {
							my $stemmedWord = porter $sourceWordsTemp[$j];
							my $gram = $stemmedWord;

							for (my $k = 1; $k < $N; $k++) {
								$stemmedWord = porter $sourceWordsTemp[$j+$k];
								$gram .= " $stemmedWord";
							}

							#print "$gram\n";

							if (exists $sourceWords{$gram}) {
								$sourceWords{$gram} +=1;
							}
							else {
								$sourceWords{$gram} = 1;
								$allWords{$gram} = 1;
							}
						}
						#print "-------------------------\n";
					}
				}
				close INPUTDOC1;

				print OUTPUT keys (%sourceWords) . "\t";
			}
			else {
				print "Doc doesn't exist: $sourceFile";
			}
			#count length of document 2
			my $targetFile = $data[5];

			if (-e $targetFile) {
				open INPUTDOC2, $targetFile; # or die "Couldn't open file $targetFile: $!\n";

				while (<INPUTDOC2>) {

					my @sentenceTemp = split(/[?!\.]+/, $_);
					my $sentenceSize = scalar @sentenceTemp;

					for (my $i=0; $i < $sentenceSize; $i++) {

						$_ = $sentenceTemp[$i];
						chomp($_);
						s/^\s+//;
						s/\s+$//;

						my @targetWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
						my $size = scalar @targetWordsTemp;
						for (my $j = 0; $j < ($size-$N+1); $j++) {
							my $stemmedWord = porter $targetWordsTemp[$j];
							my $gram = $stemmedWord;

							for (my $k = 1; $k < $N; $k++) {
								$stemmedWord = porter $targetWordsTemp[$j+$k];
								$gram .= " $stemmedWord";
							}

							#print "$gram\n";

							if (exists $targetWords{$gram}) {
								$targetWords{$gram} +=1;
							}
							else {
								$targetWords{$gram} = 1;
								$allWords{$gram} = 1;
							}
						}
						#print "-------------------------\n";
					}
				}
				close INPUTDOC2;
				print OUTPUT keys (%targetWords) . "\t";
			}
			else {
				print "Doc doesn't exist: $targetFile";
			}
			if ((-e $targetFile) && (-e $translatedSourceFile)) {

				my $overlap = 0;
				my $sigmaFreqMultiple = 0;
				my $denominator = 0;

				my $sigmaSourceFreqSquare =0;
				my $sigmaTargetFreqSquare = 0;

				my $totalTargetWords = 0;
				my $totalSourceWords = 0;

				for my $key (keys %targetWords) {
					$totalTargetWords += $targetWords{$key};
				}

				for my $key (keys %sourceWords) {
					$totalSourceWords += $sourceWords{$key};
				}

				for my $key (keys %allWords) {
					#print "$key\t";
					my $sourceFreq = 0;
					if (exists $sourceWords{$key}) {
						$sourceFreq = $sourceWords{$key};

						#normalise by the length of the document
						$sourceFreq = $sourceFreq/$totalSourceWords;
					}

					my $targetFreq = 0;
					if (exists $targetWords{$key}) {
						$targetFreq = $targetWords{$key};
						#normalise by the length of the document
						$targetFreq = $targetFreq/$totalTargetWords;
					}

					#print $sourceFreq . "\t" . $targetFreq . "\n";
					$sigmaFreqMultiple += $sourceFreq * $targetFreq;
					$sigmaTargetFreqSquare += $targetFreq*$targetFreq;
					$sigmaSourceFreqSquare += $sourceFreq*$sourceFreq;
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