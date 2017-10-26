#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;

use List::Util qw(min);
use List::Util qw(max);

sub URLLevelAndCharacterOverlapSub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	my $sourcedata = $args[2];
	my $outputPath = $args[3];

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	my $output = $outputPath . "$source-$target-output/$source-$target-URLLevelAndCharacterOverlap.txt";

	open INPUT, $sourcedata or die "Couldn't open file $sourcedata: $!\n";
	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tURL1\tURL2\tLevelOverlap\tCharacterOverlap\n";
	while (<INPUT>) {
		if (/DocName_1/) {
		}
		else {
			my @data = split(/[\t]/, $_);

			my $comparabilityLevel = "null";
			my $docName1 = $data[0];
			my $url1 = $data[3];
			my $docName2 = $data[4];
			my $url2 = $data[7];

			$url1 =~ s/http:\/\///;
			$url2 =~ s/http:\/\///;
			chomp($url1);
			chomp($url2);

			if ($url1 eq $url2) {
				print OUTPUT "$comparabilityLevel\t$docName1\t$docName2\t$url1\t$url2\t\t\n";
				#ignore file because path is the same
			}
			else {

				print OUTPUT "$comparabilityLevel\t$docName1\t$docName2\t$url1\t$url2\t";
				#print "$url1\t$url2\n";

				my @url1Data = split(/[\/]+/, $url1);
				my @url2Data = split(/[\/]+/, $url2);

				my $url1size = scalar @url1Data;
				my $url2size = scalar @url2Data;

				my $size = min $url1size,$url2size;
				my $maxSize = max $url1size,$url2size;

				my $levelOverlap = 0;
				for (my $i = 0; $i < $size; $i++) {
					if ($url1Data[$i] ne $url2Data[$i]) {
						last;
					}
					else {
						$levelOverlap++;
					}
				}
				my $normalisedLevelOverlap = "null";

				if ($levelOverlap > 0) {
					$normalisedLevelOverlap = $levelOverlap/$maxSize;
				}
				print OUTPUT "$normalisedLevelOverlap\t";
				#print "$levelOverlap\t";

				@url1Data = split(/[\/]*/, $url1);
				@url2Data = split(/[\/]*/, $url2);

				$url1size = scalar @url1Data;
				$url2size = scalar @url2Data;

				$size = min $url1size,$url2size;			
				$maxSize = max $url1size,$url2size;

				my $characterOverlap = 0;
				for (my $i = 0; $i < $size; $i++) {
					if ($url1Data[$i] ne $url2Data[$i]) {
						last;
					}
					else {
						$characterOverlap++;
					}
				}
				my $normalisedScore = "null";

				if ($characterOverlap != 0) {
					$normalisedScore = $characterOverlap/$maxSize;
				}
				print OUTPUT "$normalisedScore\n";
				#print "$characterOverlap\n";
			}
		}
	}
}
1;