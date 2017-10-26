#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use porter;

my ($sourcedata, $output, $targetFile, $sourceFile, @words);
my (%sourceWords, %targetWords, %allWords);


sub TermFreqOverlapStemmedCosineSimilaritySub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	my $sourcedata = $args[2];
	my $outputPath = $args[3];

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	$output = $outputPath . "$source-$target-output/$source-$target-TermFreqOverlap-Stemmed-CosineSimilarity.txt";

	#open source data and output
	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tNumberOfUniqueWords1\tNumberOfUniqueWords2\tCosineSimilarity-NormalisedTermFreq\n";

	while (<INPUT>) {

		%allWords = ();

		my $sentence = $_;
		
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

			print OUTPUT "$comparabilityLevel\t$docName1\t$docName2\t"; 

			my $translatedSourceFile = $data[1];

			if (-e $translatedSourceFile) {
				open INPUTDOC1, $translatedSourceFile or die "Couldn't open file $translatedSourceFile: $!\n";

				while (<INPUTDOC1>) {
					my @sourceWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					my $size = scalar @sourceWordsTemp;
				
					for (my $i = 0; $i < $size; $i++) {

						my $stemmedWord = porter $sourceWordsTemp[$i];
						if (exists $sourceWords{$stemmedWord}) {
							$sourceWords{$stemmedWord} +=1;
						}
						else {
							$sourceWords{$stemmedWord} = 1;
							$allWords{$stemmedWord} = 1;
						}
					}
				}
				close INPUTDOC1;
				print OUTPUT keys (%sourceWords) . "\t";
			}
			else {
				print OUTPUT "null\t";
				print "Doc doesn't exist: $translatedSourceFile";
			}
			#count length of document 2
			my $targetFile = $data[5];

			if (-e $targetFile) {
				open INPUTDOC2, $targetFile; # or die "Couldn't open file $targetFile: $!\n";

				while (<INPUTDOC2>) {
					my @targetWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					my $size = scalar @targetWordsTemp;
					for (my $i = 0; $i < $size; $i++) {

						my $stemmedWord = porter $targetWordsTemp[$i];

						if (exists $targetWords{$stemmedWord}){
							$targetWords{$stemmedWord} +=1;
						}
						else {
							$targetWords{$stemmedWord} =1;
							$allWords{$stemmedWord} = 1;
						}
					}
				}
				close INPUTDOC2;
				print OUTPUT keys (%targetWords) . "\t";
			}
			else {
				print OUTPUT "null\t";
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

				my $cosine = 0;
				if ($denominator == 0) {
					$cosine = "null";
				}
				else {
					$cosine = $sigmaFreqMultiple/$denominator;
				}

				print OUTPUT "$cosine";
			}
			else {
				print OUTPUT "null";
			}
			print OUTPUT "\n";
		}
	}
}
1;