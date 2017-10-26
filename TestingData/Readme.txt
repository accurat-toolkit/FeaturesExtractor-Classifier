This file lists an example to run features extractor and classifier to measure comparability level of a set of unknown document pairs.
As testing data, we used HR-EN comparable corpus which contain automatically retrieved news documents in Croatian and English, 
while the training data used the features extracted from HR-EN Initial Comparable Corpora.

To run the tool using the testing data, please enter the following command (please note that any absolute path will need to be modified
based on the environment):

1. The first example shows the way to call Classifier.pl by providing the information of all the required files: original documents, translated
documents and HTML documents:

perl Classifier.pl --source Croatian --target English --input H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\Source_all.txt --input 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\Target_all.txt --sourcetranslation 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\TranslatedSource.txt --sourcehtml 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\TestingData\HTMLSource_all.txt --targethtml 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\TestingData\HTMLTarget_all.txt --output comparabilityList_all.txt --param threshold=3

2. In the second example, no path to the translation files are provided. Therefore, the tool will automatically send request to translation
API to translate the required documents. The testing data for this example includes a reasonably smaller number of documents:

perl Classifier.pl --source Croatian --target English --input H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\Source.txt --input 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\Target.txt --sourcehtml H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\HTMLSource.txt 
--targethtml H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\HTMLTarget.txt --output 
H:\ACCURAT\FeaturesExtractor-Classifier\comparabilityList.txt --param threshold=3

TestingData folder also contains a training file for HR-EN classifier, which is extracted from the HR-EN Initial Comparable Corpora. To train
documents, please use this command:

perl TrainDocuments.pl --source HR --target EN --input TestingData\HR-EN-summary_ICC.txt --model TestModel --param "mapping=1 0 0 0 2 3 4"

and to classify the documents using the new model please use this command:

perl Classifier.pl --source Croatian --target English --input H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\Source.txt --input 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\Target.txt --sourcetranslation 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\TranslatedSource.txt --sourcehtml 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\TestingData\HTMLSource_all.txt --targethtml 
H:\ACCURAT\FeaturesExtractor-Classifier\TestingData\TestingData\HTMLTarget_all.txt --output comparabilityList_all.txt --param model=TestModel
--param threshold=3
