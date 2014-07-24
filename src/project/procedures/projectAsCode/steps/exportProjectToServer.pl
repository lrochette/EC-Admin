#############################################################################
#
# Copyright 2014 Electric-Cloud Inc.
#
#############################################################################

$[/myProject/scripts/perlHeader]
use XML::LibXML;
use File::Path;

#############################################################################
#
# Parameters
#
#############################################################################
my $prj="$[Project]";		# name of the project to transform

#############################################################################
#
# Global Variables
#
#############################################################################
my $DEBUG=1;		# Debug mode
my $manifest = ""; 	# manifest.pl file content

# Use the logs directory for the temporary export file (we know it's writable by the
# server since it writes its logs there).
my $exportFile = $ec->getProperty("/server/Electric Cloud/dataDirectory")
        		->findvalue("//value")->value() . "/logs/project.xml";


#Create the export file
# use ElectricCommander;
$ec->export($exportFile,{
	 path => "/projects/$prj",
	 excludeJobs => 'true',
	 relocatable => 'true',
	 withNotifiers => 'true'
});



