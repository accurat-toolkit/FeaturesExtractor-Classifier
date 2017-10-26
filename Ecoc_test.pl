#!/usr/bin/perl -w

# Runs error-correcting output codes with svm_perf 
# Written by E. Kanoulas and M. Paramita
# Last update 16 August 2011

# use module
use warnings;
use strict;

my $sourceLang = $ARGV[0];
my $targetLang = $ARGV[1];
#number of classes
my $k = $ARGV[2];

# The language pair identifier
my $lang = "$sourceLang-$targetLang";
my $threshold = $ARGV[7];
my $inputFile = $ARGV[3];
my $processedFile = $ARGV[4];
my $outputFolder = "output";
my $modelFolder = $ARGV[5];
my $outputFile = $ARGV[6];
# The class mapping
my @mapping = @ARGV[8..$#ARGV];
my $m = join(' ',@mapping);
my $mf = join('',@mapping);

#check whether model folder exists
if (-d $modelFolder) {
}
else {
	print "Classifier models are not found in $modelFolder. Please run trainDocuments.pl beforehand.\n";
	exit();
}

#check whether output folder exists
if (-d $outputFolder) {
}
else {
	print "Output directory does not exist. Creating new directory \"$outputFolder\"....\n";
	system("mkdir $outputFolder");
	print "Directory has been created.\n";

}
# Generate codewords for each one of the classes
# codewords{class}[classifier]
my %codewords=();
my ($i,$j)=0;
for ($i=1;$i<=$k;$i++){
    for ($j=1;$j<=2**($k-1)-1;$j++){
	my $digit = ($j/(2**($k-$i))+1) % 2;
	if (exists $codewords{$i}){
	    push(@{$codewords{$i}},$digit);}
	else{
	    @{$codewords{$i}} = ($digit);}
    }
    #print join('',@{$codewords{$i}})."\n";
}
# For each mapping
# For each one of the classifiers
my @predsc=();

for ($j=0;$j<2**($k-1)-1;$j++){
    
    print "----Classifier :";
    for ($i=1;$i<=$k;$i++){
  		my $cw =  $codewords{$i}[$j];
  		print "$cw";
    }
    print "\n";
 
    my @classifiers = glob("$modelFolder/model_$lang\.F$mf\_*_class$j");
    my $classifier = $classifiers[0];
	print $classifiers[0] . "\n";
    system("svm_classify $processedFile $classifier $outputFolder/output_file_test_$lang\_F$mf\_class$j");

	#addition to discover the classes for the data
	open(PREDICT,"$outputFolder/output_file_test_$lang\_F$mf\_class$j") or die "Could not open $outputFolder/output_file_test_$lang\_F$mf\_class$j";

	my $inst=0;
	while (<PREDICT>){
	    my $tmp = 1;
	    if ($_ =~ /-.*/){
			$tmp = 0;}
	    #my @tmp = split(/ /,$_);
	    if (exists $predsc[$inst]){
			$predsc[$inst] = "$predsc[$inst]$tmp";}
		else{
			$predsc[$inst] = $tmp;}
		$inst++;
	}
	close(PREDICT);
}
open OUTPUT, "> $outputFile" or die "Could not open $outputFile: $!\n";

my @filesList = ();
open INPUT, "$inputFile" or die "Could not open $inputFile\n";
while (<INPUT>) {
	my @temp = split(/\t/, $_);
	if ($_ =~ m/SourceFile/) {
	}
	else {
		push(@filesList, $temp[0] . "\t" . $temp[1]);
	}
}
close INPUT;

my $index = 0;
my @pred=();
foreach my $predc (@predsc){
	my $minhdist = 1000;my $minhdisti = 0;
	for ($i=1;$i<=$k;$i++){
		my $hdist = hd($predc,join('',@{$codewords{$i}}));
		if ($hdist <= $minhdist){
			$minhdist = $hdist;
			$minhdisti = $i;
		}
	}
	push(@pred,$minhdisti);
	if ($minhdisti >= $threshold) {
		print OUTPUT $filesList[$index] . "\t" . $minhdisti . "\n";
	}
	$index++;
}
close OUTPUT;

# Hamming distance between two strings
sub hd{ length( $_[ 0 ] ) - ( ( $_[ 0 ] ^ $_[ 1 ] ) =~ tr[\0][\0] ) }

# Maximum
sub max {
    $_[ 0 ] < $_[ -1 ] ? shift : pop while @_ > 1;
    return @_;
}

# Minimum
sub min {
    $_[ 0 ] > $_[ -1 ] ? shift : pop while @_ > 1;
    return @_;
}
