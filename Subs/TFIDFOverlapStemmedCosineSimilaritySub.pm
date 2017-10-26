#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;
use porter;

my ($sourcedata, $docFreqData, $output, $wordsDocData, $targetFile, $sourceFile, @words);
my (%sourceWords, %targetWords, %allWords, %docFreqs);

my ($overlap, $sigmaFreqMultiple, $denominator, $sigmaSourceFreqSquare, $sigmaTargetFreqSquare, $totalSourceWords, $totalTargetWords);

sub TFIDFOverlapStemmedCosineSimilaritySub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	$sourcedata = $args[2];
	my $outputPath = $args[3];

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	$output = $outputPath . "$source-$target-output/$source-$target-TFIDFOverlap-Stemmed-CosineSimilarity.txt";

	$docFreqData = $outputPath . "$source-$target-output/$source-$target-WordsFrequenciesForEachFile-all-stemmed.txt";
	$wordsDocData = $outputPath . "$source-$target-output/$source-$target-ListOfFilesForEachWords-all-stemmed.txt";

	#open source data and output
	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";
	open DF, $docFreqData or die "Couldn't open file $docFreqData: $!\n";
	open WD, $wordsDocData or die "Couldn't open file $wordsDocData: $!\n";

	my $testOutput = $wordsDocData = $outputPath . "$source-$target-output/ListWordsAndFreq.txt";

	open TESTOUTPUT, "> $testOutput" or die "Couldn't open file $testOutput: $!\n";

	#so that line isn't counted
	my $numberOfDoc = 0; 

	while (<DF>) {
		$numberOfDoc++;
	}
	close(DF);

	print "Loading the document frequency for each word ...\n";
	while (<WD>) {
		my $sentence = $_;
		chomp ($sentence);
		my @data = split(/[\t]/, $sentence);

		my $word = $data[0];
		chomp $word;
		my $docFreq = $data[1];

		$docFreqs{$word} = $docFreq;

		print TESTOUTPUT "$word\t$docFreq\n";
	}
	close(WD);

	print "Counting TF IDF for each file ... \n";
	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tNumberOfUniqueWords1\tNumberOfUniqueWords2\tCosineSimilarity-TF*IDF\n";
	while (<INPUT>) {

		%allWords = ();

		my $sentence = $_;
		
		if ($sentence =~ /DocName_1/) {
			#ignore the first sentence
		}
		else {
			my @data = split(/\t/, $_);

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
				open INPUTDOC1, "<:encoding(utf8)", $translatedSourceFile or die "Couldn't open file $translatedSourceFile: $!\n";

				while (<INPUTDOC1>) {
					$_ = lc $_;
					my @sourceWordsTemp = split(/[ \t\":;\-_\',&*\+?!.\(\)\/]+/, $_);
					                      
					my $size = scalar @sourceWordsTemp;
				
					for (my $i = 0; $i < $size; $i++) {

						my $unStemmedWord = $sourceWordsTemp[$i];
						chomp $unStemmedWord;
						my $stemmedWord = porter $unStemmedWord;

						if (exists $sourceWords{$stemmedWord}) {
							$sourceWords{$stemmedWord} +=1;
						}
						else {
							$sourceWords{$stemmedWord} = 1;
							$allWords{$stemmedWord} = 1;
						}
					}
				}
				print OUTPUT keys (%sourceWords) . "\t";
			}
			else {
				print OUTPUT "null\t";
				print "Doc doesn't exist: $translatedSourceFile\n";
			}
			#count length of document 2
			my $targetFile = $data[5];

			if (-e $targetFile) {
				open INPUTDOC2, "<:encoding(utf8)", $targetFile; # or die "Couldn't open file $targetFile: $!\n";

				while (<INPUTDOC2>) {
					$_ = lc $_;
					my @targetWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					my $size = scalar @targetWordsTemp;
					for (my $i = 0; $i < $size; $i++) {

						my $unStemmedWord = $targetWordsTemp[$i];
						chomp $unStemmedWord;
						my $stemmedWord = porter $unStemmedWord;

						if (exists $targetWords{$stemmedWord}){
							$targetWords{$stemmedWord} +=1;
						}
						else {
							$targetWords{$stemmedWord} =1;
							$allWords{$stemmedWord} = 1;
						}
					}
				}
				print OUTPUT keys (%targetWords) . "\t";
			}
			else {
				print OUTPUT "null\t";
				print "Doc doesn't exist: $targetFile\n";
			}
			if ((-e $targetFile) && (-e $translatedSourceFile)) {

				$overlap = 0;
				$sigmaFreqMultiple = 0;
				$denominator = 0;
				$sigmaSourceFreqSquare =0;
				$sigmaTargetFreqSquare = 0;

				$totalSourceWords = 0;
				$totalTargetWords = 0;

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
						#print "$sourceFreq\t";
						#normalise by the length of the document
						$sourceFreq = $sourceFreq/$totalSourceWords;
						#print "$sourceFreq\t";
						#get the idf
						if (exists $docFreqs{$key}) {
							my $df = log($numberOfDoc/$docFreqs{$key});
							#print "$df\n";
							$sourceFreq *= $df;
						}
						else {
							#print "$key\n";
						}
					}

					my $targetFreq = 0;
					if (exists $targetWords{$key}) {
						$targetFreq = $targetWords{$key};
						#print "$targetFreq\t";
						#normalise by the length of the document
						$targetFreq = $targetFreq/$totalTargetWords;
						#print "$targetFreq\t";
						#get the idf
						if (exists $docFreqs{$key}) {
							my $df = log($numberOfDoc/$docFreqs{$key});
							#print "$df\n";
							#multiply with the idf
							$targetFreq *= $df;
						}
						else {
							print $key . "\n";
						}
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