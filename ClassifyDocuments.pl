use List::Util 'max'; 

# Written by M. Paramita (m.paramita@sheffield.ac.uk)
# Last update 16 August 2011

my $temp = "@ARGV";
if (($temp =~ m/--input/) && ($temp =~ m/--output/) && ($temp =~ m/--source/) && ($temp =~ m/--target/) && 
($temp =~ m/--param/)) {
}
else
{ 
  print "Missing parameter. Please run the tool based on the guideline below.\n\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  print "To run this script, please use the following arguments:\n\n";
  print "     \"perl ClassifyDocuments.pl --source [sourceLang] --target [targetLang] --input [featuresFile] \n";
  print "     --model [modelFolder] --output [outputFile] --param \"mapping=[space-separated class mapping]\"\n\n";
  print "An example of its use is:\n\n";
  print "     \"perl ClassifyDocuments.pl --source HR --target EN --input C:\\ACCURAT\\HR-EN-summary.txt\n";
  print "     --model C:\\ACCURAT\model\ --output C:\\ACCURAT\\HR-EN-summary-output.txt\n";
  print "     --param \"mapping=1 0 0 0 2 3 4\"\"\n";
  print "-------------------------------------------------------------------------------------------------------\n";
  exit;
}
my $threshold = 0;
my ($sourceLang, $targetLang, $inputFile, $outputFile, $modelFolder, $param);
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
	elsif ($ARGV[$i] eq "--output") {
		$outputFile = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--model") {
		$modelFolder = $ARGV[$i+1];
	}
	elsif ($ARGV[$i] eq "--param") {
		$param = $ARGV[$i+1];
		if ($param =~ m/mapping/) {
			my @temp = split(/=/, $param);
			@mapping = split(/ /, $temp[1]);
		}
		elsif ($param =~ m/threshold/) {
			my @temp = split(/=/, $param);
			$threshold = $temp[1];
		}
		else {
		}
	}
	else {
		print "Format $ARGV[$i] is not recognized. Please correct the format and restart the tool.\n";
		exit();
	}
}

my $processedFile = $inputFile;
$processedFile =~ s/\.txt/_mapped\.txt/;

print "Processing input file ...\n";
system("perl Process.pl $inputFile $processedFile @mapping");
my $numberOfClasses = max(@mapping);
print "Classifying input file ...\n";
system("perl Ecoc_test.pl $sourceLang $targetLang $numberOfClasses $inputFile $processedFile $modelFolder $outputFile $threshold @mapping");
print "The process is finished. Result file is stored in $outputFile.\n";