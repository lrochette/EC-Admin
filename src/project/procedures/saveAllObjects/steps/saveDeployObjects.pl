#############################################################################
#
#  Copyright 2015 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

# Parameters
#
my $path="$[pathname]";

my $errorCount=0;
my $appCount=0;
my $envCount=0;
my $newtimeout=600;

# Set the time out to newtimeout so the ec commands won't time out at 3 mins
$ec->setTimeout($newtimeout);

# Check if Default project exist
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProject", "Default");
if (!$success) {
	$ec->setProperty("summary", "Project Default required to save Deploy objects");
	exit(0);
}
my $fileProjectName="Default";
my $pName="Default";

# check that we are running version 5.x or later
($success, $xPath) = InvokeCommander("SuppressLog", "getVersions");
my $version=$xPath->{responses}->[0]->{serverVersion}->{version};
printf("%s\n",$version);
if (compareVersion($version, "5.0") < 0) {
  $ec->setProperty("summary", "Version 5.0 or greater is required to save Deploy objects");
  exit(0); 
}

# Create the Projects directory for Default
mkpath("$path/Projects");
chmod(0777, "$path/Projects");
mkpath("$path/Projects/$fileProjectName");
chmod(0777, "$path/Projects/Default");
  
  
#
# Save Applications
#
mkpath("$path/Projects/$fileProjectName/Applications");
chmod(0777, "$path/Projects/$fileProjectName/Applications");

my ($success, $xPath) = InvokeCommander("SuppressLog", "getApplications", $pName);
foreach my $app ($xPath->findnodes('//application')) {
  my $appName=$app->{'applicationName'};
  my $fileAppName=safeFilename($appName);
  printf("  Saving Application: %s\n", $appName);

	my ($success, $res, $errMsg, $errCode) = 
    InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Applications/$fileAppName".".xml",
					{ 'path'=> "/projects/$pName/applications/$appName", 
                                        'relocatable' => 1,
                                        'withAcls'    => 1,
                                        'withNotifiers'=>1});
  
  if (! $success) {
    printf("  Error exporting %s", $appName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  }
  else {
    $appCount++;
  }
}

#
# Save workflow definitions
#
mkpath("$path/Projects/$fileProjectName/Environments");
chmod(0777, "$path/Projects/$fileProjectName/Environments");

my ($success, $xPath) = InvokeCommander("SuppressLog", "getEnvironments", $pName);
foreach my $proc ($xPath->findnodes('//environment')) {
  my $envName=$proc->{'environmentName'};
  my $fileEnvName=safeFilename($envName);
  printf("  Saving Environment Definition: %s\n", $envName);
  
  my ($success, $res, $errMsg, $errCode) = 
    InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Environments/$fileEnvName".".xml",
					{ 'path'=> "/projects/$pName/environments/$envName", 
                                        'relocatable' => 1,
                                        'withAcls'    => 1,
                                        'withNotifiers'=>1});
  
  if (! $success) {
    printf("  Error exporting %s", $envName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  }
  else {
    $envCount++;
  }
}


$ec->setProperty("preSummary", "$appCount applications exported\n  $envCount environments exported\n");
exit($errorCount);

#
# Make the name of an object safe to be a file or directory name
#
sub safeFilename {
  my $safe=@_[0];
  $safe =~ s#[\*\.\"/\[\]\\:;,=\|]#_#g;
  return $safe;
}


$[/myProject/scripts/perlLibJSON]

