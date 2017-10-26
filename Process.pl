#!/usr/bin/perl -w

# Written by E. Kanoulas and M. Paramita
# Last update 15 August 2011

# This file receives input of the features summary from the features extractor.
# 

use strict;

my $filein = $ARGV[0];
my $fileout = $ARGV[1];
my @mapping = @ARGV[2..$#ARGV];

#check whether the input file has the right format
open(FIN,$filein) || die "Could not open $filein\n";

#my $fileOut = $filein;
#$fileOut =~ s/.txt/-features.txt/;

open OUTPUT, "> $fileout" or die "Could not open $fileout: $!\n";

open(FIN,$filein) || die "Could not open $filein\n";

my $startIndex = 0;

while (<FIN>) {
	chomp($_);
	my $line = $_;
	#if file contains SourceFile tag, the format needs to be adapted
	#before sent to the classifier
	if ($line =~ m/SourceFile/) {
		#start from column 2 as col 0 and 1 contains the file names
		$startIndex = 2;
	}
	else {
		my @features = split(/[\t\n\r]/,$line);
		#my @features = split(/[\t\n\s\r]/,$line);
		my $fn = 0;

		if ($features[0] =~ m/[a-z]+/) {
			$startIndex = 2;
		}
	
		for (my $i = $startIndex; $i < scalar @features; $i++) {
			my $feature = $features[$i];
			
			if ($fn == 0){
				if ($feature eq "null") {
					print OUTPUT "null ";
				}
				elsif ($mapping[$feature-1] == 0){
					last;}
				else{
					print OUTPUT "$mapping[$feature-1] ";
				}
			}
			else{
				if ($feature ne "null"){
					print OUTPUT "$fn:$feature ";}
				#print "$feature ";}
				#else{
				#print "NaN ";}
			}
			$fn +=1;
		}
	    if ($fn>0){print OUTPUT "\n"};
    }
}
close FIN;
