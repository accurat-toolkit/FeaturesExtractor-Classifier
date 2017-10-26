#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011
use strict;
use warnings;
use utf8;
use File::Find;

#open folder
my ($directory, $input1, $input2, $output, $pairFile, $status, $HTMLstatus);
my (@url1, @url2);

sub ImageLinksWordsOverlapSub {
	$_ = shift;
	my @args = split("\t");

	my $source = $args[0];
	my $target = $args[1];
	my $path = "";
	$pairFile = $args[2];
	my $outputPath = $args[3];

	$directory = $path;
	mkdir $outputPath. "$source-$target-output/" unless (-d $outputPath. "$source-$target-output/");
	$output = $outputPath . "$source-$target-output/$source-$target-ImageLinksWordOverlap.txt";

	open OUTPUT, "> $output" or die "Couldn't open file $output: $!\n";

	open INPUT, $pairFile or die "Couldn't open file $pairFile: $!\n";

	print OUTPUT "Comparability Level\tDocName_1\tDocName_2\tLinksOut_1\tLinksOut_2\tImageLinkWordsOverlap\n";
	while (<INPUT>) {

		if (/DocName_1/) {
		}
		else
		{
			@url1 = ();
			@url2 = ();

			$HTMLstatus = "ok";

			my @data = split("\t");

			my ($comparabilityLevel, $initDocName1, $docName1, $folder1, $domain1, $genre1, $url1, $initDocName2, $docName2, $folder2, $domain2, $genre2, $url2);

			$comparabilityLevel = "null";
			print OUTPUT "$comparabilityLevel\t";
			$initDocName1 = $data[0];
			print OUTPUT "$initDocName1\t";

			$docName1 = $data[2];

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

					while ( /<img [^>]*src=[\"\']+([^( )]+)[\"\']+[>]*/gi) {
						#print "-- url1: $1\n";
						my @url1temp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $1);
						push(@url1, @url1temp);
					}
				}
				close INPUT1;
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

					while ( /<img [^>]*src=[\"\']+([^( )]+)[\"\']+[>]*/gi) {
						my @url2temp = split(/[ \t\":;\-_\',&*\+?!\.\(\)\/]+/, $1);
						#print "-- url2: $1\n";
						push(@url2, @url2temp);
					}
				}
				close INPUT2;
			}

			if ((-e $docName1) && (-e $docName2)) 
			{
				
				my $url1size = scalar @url1;
				my $url2size = scalar @url2;
				print OUTPUT "$url1size\t$url2size\t";

				my $overlap = 0;
				for(my $i = 0; $i < $url1size; $i++) {
					for (my $j = 0; $j < $url2size; $j++) {
						#This is where we match every combination of url 1 and url 2

						# if URL words equals jpg, png, gif, jpeg, www, http, ignore them all.
						if (($url1[$i] eq "jpg") || ($url1[$i] eq "jpeg") || ($url1[$i] eq "png") || ($url1[$i] eq "gif") || ($url1[$i] eq "www") || ($url1[$i] eq "http")) {
						}
						elsif (($url1[$i] eq $url2[$j]) && ($url1[$i] ne "")) {
							$url1[$i] = "";
							$url2[$j] = "";
							$overlap++;
							#print "It's the same";
						}
					}
				}
				my $normOverlap = "null";
				if ($overlap != 0) {
					$normOverlap = $overlap/($url1size*$url2size);
				}
				elsif ($url1size*$url2size > 0) {
					$normOverlap = $overlap/($url1size*$url2size);
				}

				print OUTPUT "$normOverlap";

				@url1 = ();
				@url2 = ();
			}
			else {
				print OUTPUT "null\tnull\tnull";
				@url1 = ();
				@url2 = ();

			}
			print OUTPUT "\n";
		}
	}
}
1;