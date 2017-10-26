#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

my $summaryFile = $ARGV[0];
my $validationFile = $ARGV[1];
my $trainingFile = $ARGV[2];

open FIN,$summaryFile or die "Could not open $summaryFile: $!\n";
open VALID, "> $validationFile" or die "Could not open $validationFile: $!\n";
open TRAIN, "> $trainingFile" or die "Could not open $trainingFile: $!\n";

while (<FIN>) {
	my $line = $_;
	if(rand() < 0.2) {
		print VALID $line;
	}
	else {
		print TRAIN $line;
	}
}
close FIN;
close VALID;
close TRAIN;
