$[/myProject/scripts/perlHeaderJSON]

#
# Parameters
#
my $stepId="$[myJobStepId]";

#
# Global variables
#
my $path="";
my $DEBUG=0;

# let us extract some date from the original step
my ($ok, $json)=InvokeCommander("SuppressLog", 'getJobStepDetails', $stepId);
# print Dumper ($json);

my $postpCommand=$json->{responses}->[0]->{jobStep}->{postProcessor};
my $logFile=$json->{responses}->[0]->{jobStep}->{logFileName};
my $resourceName=$json->{responses}->[0]->{jobStep}->{resourceName};

printf("Resource: %s\n", $resourceName) if ($DEBUG);
printf("log file: %s\n", $logFile) if ($DEBUG);
printf("postp   : %s\n", $postpCommand) if ($DEBUG);

my $wksp=$json->{responses}->[0]->{jobStep}->{workspace};

my ($ok, $resJson)=InvokeCommander("SuppressLog", 'getResource', $resourceName);
my $platform=$resJson->{responses}->[0]->{resource}->{hostPlatform};

# let's get the directory path based on the platform
# and append the log filename
if ($platform eq "windows") {
	$path=$wksp->{winDrive} . '\\' . $logFile;
} else {
	$path=$wksp->{unix} . '/' . $logFile;
}
printf("path    : %s\n", $path) if ($DEBUG);

$ec->setProperty("/myJob/pathToLog", "$path");
$ec->setProperty("/myJob/assignedResource", $resourceName);
$ec->setProperty("/myJob/postpCommand", $postpCommand);



$[/myProject/scripts/perlLibJSON]










