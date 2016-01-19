#############################################################################
#
# Copyright 2014 Electric-Cloud Inc.
#
#############################################################################
use strict;
use warnings;
use XML::LibXML;
use File::Path;
use Data::Dumper;

$| = 1;
my $DEBUG=1;

#
# Global variables
#
my $manifest = qq(\@files = \(\n); # manifest.pl file content
my $PSManifestPath='//project/propertySheet/property[propertyName="scripts"]/propertySheet';

sub fileFriendly($) {
# Replace file-name reserved characters with % equivalent

# Windows reserved characters:  "   <   >   \   ^   |   :   /   *   ?
# Linux reserved characters: &
# Commander allows all of these, but double quote will cause parsing of manifest.pl to fail

#
#   "   <   >   \   ^   |   :   /   *   ?
# %22 %3C %3E %5C %5E %7C %3A %2F %2A %3F

	my $inputString = shift;
	$inputString =~ s/\"/%22/g;
	$inputString =~ s/\</%3C/g;
	$inputString =~ s/\>/%3E/g;
	$inputString =~ s/\\/%5C/g;
	$inputString =~ s/\^/%5E/g;
	$inputString =~ s/\|/%7C/g;
	$inputString =~ s/\:/%3A/g;
	$inputString =~ s/\//%2F/g;
	$inputString =~ s/\*/%2A/g;
	$inputString =~ s/\?/%3F/g;
	return $inputString;
}

sub processPS {
# Recursive function to process a PS and create a file for each property

	my $node=shift;			# Node to process
	my $directory=shift;	# where to save the file
	my $propPath=shift;		# the path to access the code property
	my $spaces=shift;		# number of spaces for indentation

	# print Dumper($node) . "\n";
  	foreach my $prop ($node->findnodes('property')) {
    	my $propName=$prop->findvalue("propertyName");
    	my $propFileName=fileFriendly($propName);
	    printf(" " x $spaces . "Process $propName\n");

    	# Is this a PS, if so let's recurse
    	if ($prop->findnodes("propertySheet")) {
    		mkdir "$directory/$propFileName";
    		processPS(($prop->findnodes("propertySheet"))[0], "$directory/$propFileName", $propPath . "/property[propertyName=\"$propName\"]/propertySheet", 2 + $spaces );
    	} else {
    		# we have a normal property
	    	my $propValue=$prop->findvalue("value");

	    	$manifest .= qq(	['$propPath/property[propertyName="$propName"]/value', "$directory/$propFileName.txt"],\n);
			my $propFile = "$directory/$propFileName.txt";
			open (PROP, ">$propFile") or die "$propFile:  $!\n";
			print PROP $propValue, "\n";
			close PROP;

	    	my $node=($prop->findnodes('value'))[0];
	    	$node->removeChildNodes;			# Remove the current value
			$node->appendText('PLACEHOLDER'); 	# Insert new value
		}
	}
}

# Remove old procedures directory if it exists
rmtree("project/procedures");
mkdir "project";
mkdir "project/procedures";

# Remove old properties directory if it exists
rmtree("project/properties");

# Load export file
my $filename = "project.xml";
my $parser = XML::LibXML->new();
my $projectXml = $parser->parse_file($filename);

# Make sure project/propertySheet exists
my $projectNode=$projectXml->findnodes('/exportedData/project');
if (!$projectXml->findnodes('/exportedData/project/propertySheet')) {
	my $propertySheet = $projectXml->ownerDocument->createElement('propertySheet');
	$projectNode->[0]->appendChild($propertySheet);
}

# Add plugin properties
my $projectPropertySheet=$projectXml->findnodes('/exportedData/project/propertySheet');

# Add ec_setup -> PLACEHOLDER property
my $ec_setup = $projectXml->ownerDocument->createElement('property');
$ec_setup->appendTextChild('propertyName',"ec_setup");
$ec_setup->appendTextChild('value',"PLACEHOLDER");
$ec_setup->appendTextChild('expandable',"0");
$projectPropertySheet->[0]->appendChild($ec_setup);
my $ecSetupFile = "project/ec_setup.pl";
my $setupContent = $projectXml->find('/exportedData/project/propertySheet/property[propertyName="ec_setup"]/value')->string_value;

open (SETUP, ">$ecSetupFile") or die "$ecSetupFile:  $!\n";
print SETUP $setupContent, "\n";
close SETUP;

# check PS named "scripts" to extract code as properties
my $PS=($projectXml->findnodes('/exportedData/project/propertySheet/property[propertyName="scripts"]'))[0];
if ($PS) {
	printf("Process scripts propertySheet\n");
	mkdir "project/properties";
	mkdir "project/properties/scripts";
	chdir("project");
	processPS(($PS->findnodes("propertySheet"))[0], "properties/scripts",
						  "//project/propertySheet/property[propertyName=\"scripts\"]/propertySheet", 2);
	chdir("..");
}
# Add project_version -> @ PLUGIN_VERSION @ property
my $project_version = $projectXml->ownerDocument->createElement('property');
$project_version->appendTextChild('propertyName',"project_version");
$project_version->appendTextChild('value','@'.'PLUGIN_VERSION'.'@');
$projectPropertySheet->[0]->appendChild($project_version);

# Replace some plugin values
#exportPath: /projects/exportPath -> /projects/@PLUGIN_KEY@
my $exportPathNode=($projectXml->findnodes('/exportedData/exportPath'))[0];
$exportPathNode->removeChildNodes;  # Remove the current value
$exportPathNode->appendText('/projects/@'.'PLUGIN_KEY'.'@'); # Insert new value
#projectName -> @ PLUGIN_KEY @
my $projectNameNode=($projectXml->findnodes('/exportedData/project/projectName'))[0];
$projectNameNode->removeChildNodes;  # Remove the current value
$projectNameNode->appendText('@'.'PLUGIN_KEY'.'@'); # Insert new value

$manifest .= qq(	['//project/propertySheet/property[propertyName="ec_setup"]/value', 'ec_setup.pl'],\n);

foreach my $procedure ($projectXml->findnodes('/exportedData/project/procedure')) {

	my $procedureName = $procedure->find("procedureName")->string_value;
	printf("Processing procedure: $procedureName\n") if ($DEBUG);

	# my $procedureFile = $procedureName;
	# $procedureFile =~ s/\:/_colon_/g;  # Deal with step name characters not allowed in file names
	my $procedureFile = fileFriendly($procedureName);
	mkdir "project/procedures/$procedureFile";

	# deal with ec_parameterForm property
	my $form=($procedure->findnodes('propertySheet/property[propertyName="ec_parameterForm"]/value'))[0];
	if ($form) {
		printf("    ec_parameterForm found\n") if ($DEBUG);
		my $formValue=$form->string_value;
		$form->removeChildNodes;  			# Remove the current value
		$form->appendText('PLACEHOLDER'); 	# Insert new value
		$manifest .= qq(	['//project/procedure[procedureName="$procedureName"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/$procedureFile/form.xml'],\n);
		my $formFile = "project/procedures/$procedureFile/form.xml";
		open (FORM, ">$formFile") or die "$formFile:  $!\n";
		print FORM $formValue, "\n";
		close FORM;

	}
	mkdir "project/procedures/$procedureFile/steps";
	#print "Procedure: $procedureName\n";
	foreach my $step ($procedure->findnodes('step')) {
		my $stepName = $step->find("stepName")->string_value;
		printf("  Processing step: $stepName\n") if ($DEBUG);
		my $shell = $step->find("shell")->string_value;
		my $command = $step->find("command")->string_value;
		#print "	Step: $stepName\n";
		# Replace command -> PLACEHOLDER (not for subproject steps)
		my $stepNode=($step->findnodes('command'))[0];
		if ($stepNode) {
			$stepNode->removeChildNodes;  # Remove the current value
			$stepNode->appendText('PLACEHOLDER'); # Insert new value
		}
		#
		my $ext=".sh"; # No way to detect whether sh or cmd
		if ($shell eq 'ec-perl' || $shell eq 'perl') {
			$ext = ".pl";
		} elsif ($shell =~ /powershell/) {
			$ext = ".ps1";
		}
		
		# my $stepFile = $stepName;
		# $stepFile =~ s/\:/_colon_/g;  # Deal with step name characters not allowed in file names
		my $stepFile = fileFriendly($stepName);
		#print "	Modified Step: $stepName\n";
		my $commandFile = "project/procedures/$procedureFile/steps/$stepFile${ext}";
		open (COMMAND, ">$commandFile") or die "$commandFile:  $!\n";
		print COMMAND $command, "\n";
		close COMMAND;
		$manifest .= qq(	['//project/procedure[procedureName="$procedureName"]/step[stepName="$stepName"]/command', 'procedures/$procedureFile/steps/$stepFile${ext}'],\n);
	} # step
} # procedure

$manifest .= qq(\););
open (MANIFEST, ">project/manifest.pl") or die "$!\n";
print MANIFEST $manifest, "\n";
close MANIFEST;

open (TEMPLATE, ">project/project.xml.in") or die "$!\n";
print TEMPLATE $projectXml->toString(1);
close TEMPLATE;

# delete the exported XML file
unlink("project.xml")

