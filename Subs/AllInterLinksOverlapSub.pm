#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

use List::Util 'max'; 

use strict;
use warnings;
use utf8;
use File::Find;
use List::Util;

#open folder
my ($input1, $input2, $output, $pairFile, $status, $HTMLstatus);
my (@url1, @url2);

sub AllInterLinksOverlapSub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];

	my $pairFile = $args[2];
	my $path = "";

	my $outputPath = $args[3];

	open INPUT, $pairFile or die "Couldn't open file $pairFile: $!\n";

	mkdir $outputPath unless (-d $outputPath);

	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");

	$output = $outputPath . "$source-$target-output/$source-$target-AllInterLinksOverlap.txt";

	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tLinksOut_1\tLinksOut_2\tLinkOverlap\tRatio\n";

	while (<INPUT>) {

		if (/DocName_1/) {
		}
		else
		{
			my @data = split("\t");

			my ($comparabilityLevel, $initDocName1, $docName1, $initDocName2, $docName2);

			$comparabilityLevel = "null";
			print OUTPUT "$comparabilityLevel\t";
			$initDocName1 = $data[0];
			print OUTPUT "$initDocName1\t";

			$docName1 = $data[2];

			#print "52: $docName1\n";

			my $flag = 0;
			if (-e $docName1) {
				open INPUT1, $docName1 or die "Couldn't open file $docName1: $!\n";

				while (<INPUT1>) {
					my $sentence = $_;
					chomp ($sentence);
					while ($sentence =~ /&amp;/) {
						$sentence =~ s/&amp;/&/g;
					}
					$sentence =~ s/&quot;/\"/g;
					$sentence =~ s/&\#039;/\'/g;
					$sentence =~ s/&lt;/</g;
					$sentence =~ s/&gt;/>/g;

					$_ = $sentence;
	
					while ( /<a [^>]*href=[\"\']+([^( )]+)[\"\']+[>]*/gi) {
						my $url = $1;
						push(@url1, $url);
					}
				}
				close INPUT1;
			}
			else {
				print "File $docName1 does not exist\n";
			}

			$initDocName2 = $data[4];
			print OUTPUT "$initDocName2\t";
			$docName2 = $data[6];

			if (-e $docName2) {

				open INPUT2, $docName2 or die "Couldn't open file $docName2: $!\n";
				while (<INPUT2>) {
					my $sentence = $_;
					chomp ($sentence);
					while ($sentence =~ /&amp;/) {
						$sentence =~ s/&amp;/&/g;
					}
					$sentence =~ s/&quot;/\"/g;
					$sentence =~ s/&\#039;/\'/g;
					$sentence =~ s/&lt;/</g;
					$sentence =~ s/&gt;/>/g;

					$_ = $sentence;

					while ( /<a [^>]*href=[\"\']+([^( )]+)[\"\']+[>]*/gi) {
						my $url = $1;
						push(@url2, $url);
					}
				}
				close INPUT2;
			}
			else {
				print "File $docName2 does not exist\n";
			}
			if ((-e $docName1) && (-e $docName2)) 
			{
				#print "$docName1-------$docName2\n";
				my $url1size = scalar @url1;
				my $url2size = scalar @url2;
				print OUTPUT "$url1size\t$url2size\t";

				my $overlap = 0;
				for(my $i = 0; $i < $url1size; $i++) {
					for (my $j = 0; $j < $url2size; $j++) {
						#This is where we match every combination of url 1 and url 2
						#my $url2 = $url2[$j];
						if (($url1[$i] eq $url2[$j]) && ($url1[$i] ne "")) {
							$url1[$i] = "";
							$url2[$j] = "";
							$overlap++;
							#print "It's the same";
						}
					}
				}
				my $ratio = "null";
				if ($overlap != 0) {
					$ratio = $overlap/($url1size*$url2size);
				}
				elsif ($url1size * $url2size > 0) {
					$ratio = $overlap/($url1size*$url2size);
				}
				print OUTPUT "$overlap\t$ratio";

				@url1 = ();
				@url2 = ();
			}
			else {
				print OUTPUT "null\tnull\tnull";
				@url1 = ();
				@url2 = ();
				#print "some problems";
			}
			print OUTPUT "\n";
		}
	}
}
1;