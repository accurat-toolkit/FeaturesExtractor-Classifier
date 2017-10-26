#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;
use File::Find;
use porter;

my (%wordsInTheCollection, %wordsInAFile, %fileName, %stemmedWords, @words, $input, $output, $directory, $translatedDirectory, $bigTableOutput, $element);
my @hashCollection = {};

sub IndexAllFilesSub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $sourcedata = $args[2];
	my $path = "";
	my $outputPath = $args[3];

	my %indexedFiles = ();

	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	
	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");

	$output = $outputPath . "$source-$target-output/$source-$target-ListOfFilesForEachWords-all-stemmed.txt";
	$bigTableOutput = $outputPath . "$source-$target-output/$source-$target-WordsFrequenciesForEachFile-all-stemmed.txt";

	#open directory
	open OUTPUT, ">:utf8", $output or die "Couldn't open file $output: $!\n";
	open OUTPUT1, ">:utf8", $bigTableOutput or die "Couldn't open file $bigTableOutput: $!\n";

	while (<INPUT>) {
		chomp($_);
		my $sentence = $_;
		
		if ($sentence =~ /DocName_1/) {
			#ignore the first sentence
		}
		else {
			my @data = split(/[\t]/, $_);

			my $docName1 = $data[0];
			my $translatedDocName1 = $data[1];
			#my $domain1 = $data[1];
			#my $genre1 = $data[2];
			#my $url1 = $data[3];
			my $docName2 = $data[4];
			my $translatedDocName2 = $data[5];
			#my $domain2 = $data[5];
			#my $genre2 = $data[6];
			#my $url2 = $data[7];

			my $sourceLC = lc $source;
			my $targetLC = lc $target;

			my $input = $docName1;

			if (exists $indexedFiles{$input}) {
			}
			else {
				if (-e $input) {
					print "Indexing $input\n";
					#open file
					open FILE, "<:encoding(utf8)", $input or die "Cannot open file $input: $!\n";
					
					#read sentence			
					while (<FILE>) {
						#split sentence
						@words = split(/[ \t\":;\-_\',&*\+?!.\(\)\/]+/, $_);
						$fileName{$input} = "";

						for (@words) {
							my $word = lc $_;
							chomp ($word);
							#perform stemming on all files (even files in other languages may still have some english words)
							$word = porter $word;
							if (exists $wordsInTheCollection{$word}){
								$wordsInTheCollection{$word} +=1;
							}
							else {
								$wordsInTheCollection{$word}= 1;
							}
	
							if (exists $wordsInAFile{$word}{$input}) {
								#if words already exists, increment the frequency then update the hash
								$wordsInAFile{$word}{$input} += 1;
							}
							else {
								#if word does not exist, add element to hash and assign the frequency to 1
								$wordsInAFile{$word}{$input} = 1;
							}
						}
					}
					close FILE;
					$indexedFiles{$input} = 1;
				}
			}

			$input = $translatedDocName1;
			if (exists $indexedFiles{$input}) {
			}
			else {
				if (-e $input) {
					print "Indexing $input\n";
					#open file
					open FILE, "<:encoding(utf8)", $input or die "Cannot open file $input: $!\n";
					
					#read sentence			
					while (<FILE>) {
						#split sentence
						@words = split(/[ \t\":;\-_\',&*\+?!.\(\)\/]+/, $_);
						$fileName{$input} = "";
	
						for (@words) {
							my $word = lc $_;
							chomp ($word);
							#perform stemming on all files (even files in other languages may still have some english words)
							$word = porter $word;
							if (exists $wordsInTheCollection{$word}){
								$wordsInTheCollection{$word} +=1;
							}
							else {
								$wordsInTheCollection{$word}= 1;
							}
	
							if (exists $wordsInAFile{$word}{$input}) {
								#if words already exists, increment the frequency then update the hash
								$wordsInAFile{$word}{$input} += 1;
							}
							else {
								#if word does not exist, add element to hash and assign the frequency to 1
								$wordsInAFile{$word}{$input} = 1;
							}
						}
					}
					close FILE;
					$indexedFiles{$input} = 1;
				}
			}

			$input = $path . $docName2;

			if (exists $indexedFiles{$input}) {
			}
			else {
				if (-e $input) {
					print "Indexing $input\n";
					#open file
					open FILE, "<:encoding(utf8)", $input or die "Cannot open file $input: $!\n";
					
					#read sentence			
					while (<FILE>) {
						#split sentence
						@words = split(/[ \t\":;\-_\',&*\+?!.\(\)\/]+/, $_);
						$fileName{$input} = "";
	
						for (@words) {
							my $word = lc $_;
							chomp ($word);
							#perform stemming on all files (even files in other languages may still have some english words)
							$word = porter $word;
							if (exists $wordsInTheCollection{$word}){
								$wordsInTheCollection{$word} +=1;
							}
							else {
								$wordsInTheCollection{$word}= 1;
							}
	
							if (exists $wordsInAFile{$word}{$input}) {
								#if words already exists, increment the frequency then update the hash
								$wordsInAFile{$word}{$input} += 1;
							}
							else {
								#if word does not exist, add element to hash and assign the frequency to 1
								$wordsInAFile{$word}{$input} = 1;
							}
						}
					}
					close FILE;
					$indexedFiles{$input} = 1;
				}
			}

			$input = $translatedDocName2;
			if (exists $indexedFiles{$input}) {
			}
			else {
				if (-e $input) {
					print "$input\n";
					#open file
					open FILE, "<:encoding(utf8)", $input or die "Cannot open file $input: $!\n";
					
					#read sentence			
					while (<FILE>) {
						#split sentence
						@words = split(/[ \t\":;\-_\',&*\+?!.\(\)\/]+/, $_);
						$fileName{$input} = "";
	
						for (@words) {
							my $word = lc $_;
							chomp ($word);
							#perform stemming on all files (even files in other languages may still have some english words)
							$word = porter $word;
							if (exists $wordsInTheCollection{$word}){
								$wordsInTheCollection{$word} +=1;
							}
							else {
								$wordsInTheCollection{$word}= 1;
							}
	
							if (exists $wordsInAFile{$word}{$input}) {
								#if words already exists, increment the frequency then update the hash
								$wordsInAFile{$word}{$input} += 1;
							}
							else {
								#if word does not exist, add element to hash and assign the frequency to 1
								$wordsInAFile{$word}{$input} = 1;
							}
						}
					}
					close FILE;
					$indexedFiles{$input} = 1;
				}
			}
		}
	}
	

	#file OUTPUT (outputAll-en.txt) will contain words and all file names which contain that word and the respective frequencies
	for (sort keys %wordsInTheCollection) {
		my $word = $_;
		print OUTPUT "$word\t" . keys(%{$wordsInAFile{$word}}) . "\t";
		#for (keys %{$wordsInAFile{$word}}) {
		#	my $input = $_;
		#	print OUTPUT "$input\t$wordsInAFile{$word}{$input}\t";
		#}
		print OUTPUT "\n";
	}

	#print header
	#file OUTPUT1 will contain file names and the frequencies of each word in the collection
	print OUTPUT1 "\t";
	for (sort keys %wordsInTheCollection) {
		my $word = $_;
		print  OUTPUT1 "$word\t";
	}
	print OUTPUT1 "\n";

	for (sort keys %fileName) {
		my $fileName = $_;
		print OUTPUT1 "$fileName\t";

		#for (sort keys %wordsInTheCollection) {
		#	my $word = $_;
		#	if (exists $wordsInAFile{$word}{$fileName}) {
		#		print OUTPUT1 "$wordsInAFile{$word}{$fileName}\t";
		#	}
		#	else {
		#		print OUTPUT1 "0\t";
		#	}
		#}
		print OUTPUT1 "\n";
	}
	print "Indexing - Finished.\n";
}
1;