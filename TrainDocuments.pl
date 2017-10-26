#!/usr/bin/perl/

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

use List::Util 'max'; 

my $temp = "@ARGV";
if (($temp =~ m/--input/) && ($temp =~ m/--model/) && ($temp =~ m/--source/) && ($temp =~ m/--target/) && 
($temp =~ m/--param/)) {
}
else
{ 
  print "Missing parameter. Please run the tool based on the guideline below.\n\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  print "To run this script, please use the following arguments:\n\n";
  print "     \"perl TrainDocuments.pl --source [sourceLang] --target [targetLang] --input [featuresFile] \n";
  print "     --model [outputModelFolder] --param \"mapping=[space-separated class mapping]\"\n\n";
  print "An example of use is:\n\n";
  print "     \"perl TrainDocuments.pl --source HR --target EN --input C:\\ACCURAT\\HR-EN-summary.txt\n";
  print "      --model C:\\ACCURAT\\model --param \"mapping=1 0 0 0 2 3 4\"\"\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  exit;
}
my ($sourceLang, $targetLang, $inputFile, $outputFile, $param);
my @mapping;

my $index = 0;
for (my $i=0; $i < scalar @ARGV; $i = $i+2) {
	if ($ARGV[$i] eq "--source") {
		$sourceLang = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--target") {
		$targetLang = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--input") {
		$inputFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--model") {
		$outputFolder = $ARGV[$i+1];
		mkdir $outputFolder unless (-d $outputFolder);
	}
	elsif ($ARGV[$i] eq "--param") {
		$param = $ARGV[$i+1];
		if ($param =~ m/mapping/) {
			my @temp = split(/=/, $param);
			@mapping = split(/ /, $temp[1]);
		}
		else {
		}
	}
	else {
		print "Format $ARGV[$i] is not recognized. Please correct the format and restart the tool.\n";
		exit();
	}
}

my $mf = join('',@mapping);

#choose a subset for validation, save as $inputFile_valid.txt
my $validationFile = $inputFile;
$validationFile =~ s/\.txt/_valid\.txt/;

#use the rest as training data, save as $inputFile_train.txt
my $trainingFile = $inputFile;
$trainingFile =~ s/\.txt/_train\.txt/;

print "perl SplitPairs.pl $inputFile $validationFile $trainingFile\n";
system("perl SplitPairs.pl $inputFile $validationFile $trainingFile");

my $processedValidationFile = $validationFile;
$processedValidationFile =~ s/\.txt/_mapped_F$mf\.txt/;

my $processedTrainingFile = $trainingFile;
$processedTrainingFile =~ s/\.txt/_mapped_F$mf\.txt/;

print "perl Process.pl $trainingFile $processedTrainingFile @mapping\n";
system("perl Process.pl $trainingFile $processedTrainingFile @mapping");
print "perl Process.pl $validationFile $processedValidationFile @mapping\n";
system("perl Process.pl $validationFile $processedValidationFile @mapping");

my $numberOfClasses = max(@mapping);
print $numberOfClasses . "\n";
print "perl Ecoc_train.pl $sourceLang $targetLang $numberOfClasses $processedTrainingFile $processedValidationFile $outputFolder @mapping\n";
system("perl Ecoc_train.pl $sourceLang $targetLang $numberOfClasses $processedTrainingFile $processedValidationFile $outputFolder @mapping");
