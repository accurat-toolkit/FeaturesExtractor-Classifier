#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;
use porter;

my ($sourcedata, $output, $targetFile, $sourceFile, @words);
my (%sourceWords, %targetWords);

sub WordOverlapSub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	my $sourcedata = $args[2];
	my $outputPath = $args[3];

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	$output = $outputPath . "$source-$target-output/$source-$target-WordOverlap.txt";

	#open source data and output
	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tdocName1\tdocName2\tNumberOfUniqueWords1\tNumberOfUniqueWords2\tAbsoluteDifference\tRelativeDifference\n";
	while (<INPUT>) {

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

			#count length of document 1
			my $translatedSourceFile = $data[1];

			if (-e $translatedSourceFile) {
				open INPUTDOC1, $translatedSourceFile or die "Couldn't open file $translatedSourceFile: $!\n";

				while (<INPUTDOC1>) {
					my @sourceWordsTemp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $_);
					my $size = scalar @sourceWordsTemp;
				
					for (my $i = 0; $i < $size; $i++) {
						my $word = $sourceWordsTemp[$i];
						if (exists $sourceWords{$word}) {
						}
						else {
							$sourceWords{$word} = 1;
						}
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
						my $word = $targetWordsTemp[$i];
						if (exists $targetWords{$word}) {
						}
						else {
							$targetWords{$word} = 1;
						}
					}
				}
				close INPUTDOC2;
				print OUTPUT keys (%targetWords) . "\t";
			}
			else {
				print OUTPUT "null\t";
			}
			my $overlap = 0;

			if ((-e $targetFile) && (-e $translatedSourceFile)) {

				#print "in here: ". keys (%elWords) . "\n";
				for my $key (keys %sourceWords) {
					if (exists $targetWords{ $key })  {
						$overlap++;
						#print "$key\n";
					}
				}

				print OUTPUT "$overlap\t";

				#count relativeDifference
				my $targetHashSize = keys(%targetWords);
				my $relDiff = "null";
				if ($targetHashSize > 0) {
					$relDiff = $overlap/$targetHashSize;
				} 
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