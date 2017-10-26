#!/usr/bin/perl -w

# Runs error-correcting output codes with svm_perf 
# The validation is done by accuracy; 
# Written by E. Kanoulas and Monica Paramita
# Last update 15 August 2011


# use module
use File::Copy;
use strict;

#number of classes
my $sourceLang = $ARGV[0];
my $targetLang = $ARGV[1];
my $lang = "$sourceLang-$targetLang";
my $k = $ARGV[2];
my $trainingFile = $ARGV[3];
my $validationFile = $ARGV[4];
my $modelFolder = $ARGV[5];
my @mapping = @ARGV[6..$#ARGV];
my $mf = join('',@mapping);

my $testingFolder = "testing";
#check whether testing folder exists
if (-d $testingFolder) {
	print "There is a directory named \"$testingFolder\". Files will be over-written.\n";
	system("del /Q $testingFolder");
}
else {
	print "Testing directory does not exist. Creating new testing directory.\n";
	system("mkdir $testingFolder");
	print "Directory has been created.\n";

}
#check whether outputFolder exists. if yes, make sure there is no other model in there.
if (-d $modelFolder) {
	print "There is a directory named $modelFolder. Files will be over-written and older models will be deleted.\n";
    opendir(DIR, $modelFolder) or die $!;
    my @dots = grep {/model\_$lang/ && -f "$modelFolder/$_"   
	} readdir(DIR);

    foreach my $file (@dots) {
        unlink("$modelFolder/$file");
		print "File $modelFolder/$file has been deleted.\n";
    }
}
else {
	print "Output directory does not exist. Creating new directory ...\n";
	system("mkdir $modelFolder");
	print "Directory has been created.\n";
}

my $filein = $trainingFile;
#my $langf = $ARGV[1];
#(my $lang = $langf) =~ s/.txt//;

#open(RES,">resultsECOC_int_ft.txt");

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

# Generate training sets out of train.txt with binary classes
# according to the codewords for each one of the classifiers.
for ($j=0;$j<2**($k-1)-1;$j++){
	open(FIN,$trainingFile) || die $trainingFile;
	open(FOUT,">testing/train_class$j.txt") || die ">testing/train_class$j.txt";
	while (<FIN>){
		#print $_;
		if ($_ =~ /(\d)[\s\t](\d.*)/){
		my $label = ${$codewords{$1}}[$j] * 2 - 1;
		print FOUT "$label $2\n";}
	}
	close(FIN);
	close(FOUT);
	}

	# Different c learning rate parameters
	my @cparams = (0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05, 0.1, 0.2, 0.5, 1, 2);

	# For each one of the classifiers
	for ($j=0;$j<2**($k-1)-1;$j++){

	print "Classifier :";
	for ($i=1;$i<=$k;$i++){
		my $cw =  $codewords{$i}[$j];
		print "$cw";
	}
	print "\n";

	my @OA=();
	my $iter = 0;

	# For each parameter c
	foreach my $c (@cparams){

		$iter++;
		print "Training for c = $c\n";
		system("svm_learn -c $c -v 0 testing/train_class$j.txt testing/model_$iter\_class$j");
		print "Validating for c = $c\n";
		system("svm_classify $validationFile testing/model_$iter\_class$j testing/output_file_$iter\_class$j");
		
		my @pred=(); my @act=();
		open(PREDICT,"testing/output_file_$iter\_class$j") or die "Could not open testing/output_file_$iter\_class$j";
		while (<PREDICT>){
		my $tmp = 1;
		if ($_ =~ /-.*/){
			$tmp = 0;}
		push(@pred,$tmp);
		}
		close(PREDICT);

		open(ACTUAL,$validationFile) or die "Could not open $validationFile";
		while (<ACTUAL>){
		my @tmp = split(/[\t\s]+/,$_);
		push(@act,$codewords{$tmp[0]}[$j]);
		}
		close(ACTUAL);
		my $acc = accuracy(\@pred,\@act);
		#my ($acacc, $acaccl_ref, $count_ind) = avgclassaccuracy(\@pred,\@act, $k);
		print "Overall Accuracy = $acc\n";
		#print "Average Accuracy = $acacc\n";
		push(@OA,$acc);
	}

	my $ind = 0; my $maxacc = 0; my $maxind = 1;
	foreach my $acc (@OA){
		if ($acc > $maxacc){
		$maxacc = $acc;
		$maxind = $ind+1;}
		$ind++;
	}

	my $c = $cparams[$maxind-1];
	print "Best c = $c and index = $maxind\n";
	#use the highest performing classifier
	#move("testing/model_$maxind\_class$j","model/model_$lang\_$maxind\_class$j");  
	move("testing/model_$maxind\_class$j","$modelFolder/model_$lang\.F$mf\_$maxind\_class$j");  
	print "Moving testing/model_$maxind\_class$j to $modelFolder/model_$lang\.F$mf\_$maxind\_class$j\n";
} 

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

# Overall Accuracy
sub accuracy{
    my (@array1) = @{$_[0]};
    my (@array2) = @{$_[1]};
    my $count = 0;
    for (my $i=0; $i<= $#array1; $i++){
	if ($array1[$i] == $array2[$i]){$count++};
    }
    my $OA=$count/($#array1+1);
    return $OA."\n";
}

sub avgclassaccuracy{
    my (@array1) = @{$_[0]};
    my (@array2) = @{$_[1]};
    my $k = $_[2];
    my %count=(); 
    my %counta=();
    

    for (my $classp = 1; $classp<=$k; $classp++){
	$counta{$classp}=0;
	for (my $classa = 1; $classa<=$k; $classa++){
	    $count{$classp}{$classa} = 0; 
	}
    }
    
    for (my $i=0; $i<= $#array1; $i++){
	$count{$array1[$i]}{$array2[$i]}++;
	$counta{$array2[$i]}++;
    }
    
    my $CA=0; my @CAL=(); my $numclass = 0;
    for (my $classp = 1; $classp<=$k; $classp++){
	my $tmp = $count{$classp}{$classp}/$counta{$classp};
	push(@CAL, $tmp);
	$CA = $CA + $tmp;
	
	if ($counta{$classp}>0){$numclass++;}
    }
    #print "Num of Classes = $numclass\n";
    $CA = $CA/$numclass;
    return($CA,\@CAL,\%count);
}

