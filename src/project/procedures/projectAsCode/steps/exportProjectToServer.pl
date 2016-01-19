#############################################################################
#
# Copyright 2014 Electric-Cloud Inc.
#
#############################################################################

$[/myProject/scripts/perlHeaderJSON]
#use XML::LibXML;
use File::Path;

#############################################################################
#
# Parameters
#
#############################################################################
my $prj="$[Project]";		# name of the project to transform
my $changeTracking="$[changeTracking]";

#############################################################################
#
# Global Variables
#
#############################################################################
my $DEBUG=1;		# Debug mode
my $manifest = ""; 	# manifest.pl file content

# Use the logs directory for the temporary export file (we know it's writable by the
# server since it writes its logs there).
my $exportFile = getP("/server/Electric Cloud/dataDirectory") . "/logs/project.xml";

# check that we are running version 5.x or later
my %exportOptions=(
	 path => "/projects/$prj",
	 excludeJobs => 'true',
	 relocatable => 'true',
	 withNotifiers => 'true'
);


my $version=getVersion();
if (compareVersion($version, "5.0") > 0) {
  if ($changeTracking) {
    $exportOptions{disableProjectTracking}="false";
  } else {
    $exportOptions{disableProjectTracking}="true";
  }
}


#Create the export file
# use ElectricCommander;
$ec->export($exportFile, \%exportOptions);

$[/myProject/scripts/perlLibJSON]











