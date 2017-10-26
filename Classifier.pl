#!/usr/bin/perl
use strict;
use warnings;

sub normalizeLang( $ ) {
    my( $lang ) = lc( $_[0] );
    my( %accuratlanguages ) = (
        #1
        "romanian" => "ro",
        "rum" => "ro",
        "ron" => "ro",
        "ro" => "ro",
        #2
        "english" => "en",
        "eng" => "en",
        "en" => "en",
        #3
        "estonian" => "et",
        "est" => "et",
        "et" => "et",
        #4
        "german" => "de",
        "ger" => "de",
        "deu" => "de",
        "de" => "de",
        #5
        "greek" => "el",
        "gre" => "el",
        "ell" => "el",
        "el" => "el",
        #6
        "croatian" => "hr",
        "hrv" => "hr",
        "hr" => "hr",
        #7
        "latvian" => "lv",
        "lav" => "lv",
        "lv" => "lv",
        #8
        "lithuanian" => "lt",
        "lit" => "lt",
        "lt" => "lt",
        #8
        "slovenian" => "sl",
        "slv" => "sl",
        "sl" => "sl"
    );
    return $accuratlanguages{$lang} if ( exists( $accuratlanguages{$lang} ) ); 
}
my $temp = "@ARGV";
my @parameter = ("--source", "--target", "--input", "--output", "--sourcetranslation", "--sourcehtml", "--targettranslation", "--targethtml");

my @inputFile = ();
my $threshold = "0";
my $sourceTranslationFile = "";
my $targetTranslationFile = "";
my ($sourceLang, $targetLang, $sourceFile, $targetFile, $sourceHTMLFile, $targetHTMLFile, $param, $modelFolder, $metadataFile, $resultsFile);
my @mapping;

$modelFolder = "Model";

if (($temp =~ m/--source/) && ($temp =~ m/--target/) && ($temp =~ m/--input/) && ($temp =~ m/--output/) &&
	($temp =~ m/--sourcehtml/) && ($temp =~ m/--targethtml/)) {
	my $index = 0;

	for (my $i=0; $i < scalar @ARGV; $i = $i+2) {
		if ($ARGV[$i] eq "--source") {
			$sourceLang = $ARGV[$i+1];
		}
		elsif ($ARGV[$i] eq "--target") {
			$targetLang = $ARGV[$i+1];
		}
		elsif ($ARGV[$i] eq "--input") {
			push(@inputFile, $ARGV[$i+1]);
		}
		elsif ($ARGV[$i] eq "--sourcetranslation") {
			$sourceTranslationFile = $ARGV[$i+1];
		}
		elsif ($ARGV[$i] eq "--targettranslation") {
			$targetTranslationFile = $ARGV[$i+1];
		}
		elsif ($ARGV[$i] eq "--sourcehtml") {
			$sourceHTMLFile = $ARGV[$i+1];
		}
		elsif ($ARGV[$i] eq "--targethtml") {
			$targetHTMLFile = $ARGV[$i+1];
		}
		elsif ($ARGV[$i] eq "--output") {
			$resultsFile = $ARGV[$i+1];
		}
		elsif ($ARGV[$i] eq "--param") {
			$param = $ARGV[$i+1];
			if ($param =~ m/mapping/) {
				my @temp = split(/=/, $param);
				@mapping = split(/ /, $temp[1]);
			}
			elsif ($param =~ m/model/) {
				my @temp = split(/=/, $param);
				$modelFolder = $temp[1];
			}
			elsif ($param =~ m/threshold/) {
				my @temp = split(/=/, $param);
				$threshold = $temp[1];
			}
		}
		else {
			print "81: Format $ARGV[$i] is not recognized. Please correct the format and restart the tool.\n";
			exit();
		}
	}
}
else
{ 
  print "Missing parameter:\n";
  foreach my $par (@parameter) {
	  if ($temp !~ /$par/) {
		  print "     $par\n";
	  }
  }
  print "Please run the tool based on the guideline below.\n\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  print "To run this script, please use the following arguments:\n\n";
  print "     \"perl Classifier.pl --source [sourceLang] --target [targetLang] --input [sourceDocsList]\n";
  print "     --input [targetDocsList] --sourcetranslation [sourceTranslationDocList] --sourcehtml [sourceHTMLList]\n";
  print "     --targettranslation [targetTranslationDocList] --targethtml [targetHTMLList] --output\n";
  print "     [comparabilityOutput] (--param threshold=[minThreshold] --param model=[modelPath] --param\n";
  print "     \"mapping=[space-separated class mapping]\")\n\n";
  print "Notes: --targettranslation is only needed for non-English target language.\n";
  print "An example of use is:\n\n";
  print "     \"perl Classifier.pl --source Croatian --target English --input C:\\sourceDocs.txt --input C:\\targetDocs.txt\n";
  print "     --sourcetranslation C:\\List_TranslatedSourceDoc.txt --sourcehtml C:\\List_HTMLSources.txt --targettranslation\n";
  print "     C:\\List_TranslatedTargetDoc.txt --targethtml C:\\List_HTMLTargets.txt --output C:\\comparabilityResult.txt\n";
  print "     --param threshold=3)\"\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  exit;
}

$sourceLang =~ tr/[a-z]/[A-Z]/;
$targetLang =~ tr/[a-z]/[A-Z]/;

my $initSourceLang = normalizeLang($sourceLang);
$initSourceLang =~ tr/[a-z]/[A-Z]/;
my $initTargetLang = normalizeLang($targetLang);
$initTargetLang =~ tr/[a-z]/[A-Z]/;

$sourceFile = $inputFile[0];
$targetFile = $inputFile[1];

#check whether translation exists. If not, call translation API.
if ($sourceTranslationFile eq "") {
	print "Translating documents of source language.\n";
	my $translationPath = $sourceFile;
	$translationPath =~ s/\\[^\\]*$/\\/g;
	
	#write list of output files in the root folder
	my $tempTranslationFile = $translationPath . "translation-output.txt";
	$sourceTranslationFile = $initSourceLang . "-translation-output.txt";
	
	mkdir "$translationPath$initSourceLang-translation" unless (-d "$translationPath$initSourceLang-translation");
	print "java -jar GoogleTranslate.jar -SL $sourceLang -TL ENGLISH -SF $sourceFile -TP $translationPath$initSourceLang-translation\n";
	system("java -jar GoogleTranslate.jar -SL $sourceLang -TL ENGLISH -SF $sourceFile -TP $translationPath$initSourceLang-translation");
	if (-e $translationPath . $sourceTranslationFile) {
		system("del $translationPath$sourceTranslationFile");
	}
	system("rename $tempTranslationFile $sourceTranslationFile");
	print "Translated files are stored in $translationPath$initSourceLang-translation.\n";
	$sourceTranslationFile = $translationPath . $sourceTranslationFile;
}
if ($targetTranslationFile eq "") {
	if ($initTargetLang eq "EN") {
		$targetTranslationFile = $targetFile;
	}
	else {
		print "Translating documents of target language.\n";
		my $translationPath = $targetFile;
		$translationPath =~ s/\\[^\\]*$/\\/g;
		
		#write list of output files in the root folder
		my $tempTranslationFile = $translationPath . "translation-output.txt"; 
		$targetTranslationFile = $initTargetLang . "-translation-output.txt";
		
		mkdir "$translationPath$initTargetLang-translation" unless (-d "$translationPath$initTargetLang-translation");
		#write the translated files in a new folder
		system("java -jar GoogleTranslate.jar -SL $targetLang -TL ENGLISH -SF $targetFile -TP $translationPath$initTargetLang-translation");
		print "Translated files are stored in $translationPath$initTargetLang-translation.\n";
		if (-e $translationPath . $targetTranslationFile) {
			system("del $translationPath$targetTranslationFile");
		}
		system("rename $tempTranslationFile $targetTranslationFile");
		$targetTranslationFile = $translationPath . $targetTranslationFile;
	}
}
$sourceLang = $initSourceLang;
$targetLang = $initTargetLang;

$metadataFile = "$sourceLang-$targetLang-pairs.txt";
my $featureFolder = "Features";
print "Creating file combinations.\n";
system("perl CreateCombinations.pl --source $sourceLang --target $targetLang --sourceFile $sourceFile --targetFile $targetFile --sourcetranslation $sourceTranslationFile --sourcehtml $sourceHTMLFile --targettranslation $targetTranslationFile --targethtml $targetHTMLFile --metadata $metadataFile");

print "Calculating Independent Features\n";
system("perl CalculateIndependentFeatures.pl --source $sourceLang --target $targetLang --metadata $metadataFile --outputFolder $featureFolder");
print "Calculating Dependent Features\n";
system("perl CalculateDependentFeatures.pl --source $sourceLang --target $targetLang --metadata $metadataFile --outputFolder $featureFolder");
print "Summarising Features\n";
system("perl FeaturesSummariser.pl --source $sourceLang --target $targetLang --outputFolder $featureFolder");
print "Classifying Documents.\n";
system("perl ClassifyDocuments.pl --source $sourceLang --target $targetLang --input $featureFolder\\$sourceLang-$targetLang-output\\$sourceLang-$targetLang-summary.txt --model $modelFolder --output $resultsFile --param \"mapping=1 0 0 0 2 3 4\" --param \"threshold=$threshold\"");
