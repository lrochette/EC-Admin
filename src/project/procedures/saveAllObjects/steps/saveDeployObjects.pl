#############################################################################
#
#  Copyright 2015 Electric-Cloud Inc.
#
# Script to backup the Deploy objects (application, environment, components)
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

# Parameters
#
my $path='$[pathname]';

my $errorCount=0;
my $appCount=0;
my $envCount=0;
my $compCount=0;

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

# Check if Default project exist
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProject", "Default");
if (!$success) {
  $ec->setProperty("summary", "Project Default required to save Deploy objects");
  exit(0);
}
my $fileProjectName="Default";
my $pName="Default";

# check that we are running version 5.x or later
my $version=getVersion();
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

  mkpath("$path/Projects/$fileProjectName/Applications/$fileAppName");
  chmod(0777, "$path/Projects/$fileProjectName/Applications/$fileAppName");
  my ($success, $res, $errMsg, $errCode) = 
    InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Applications/$fileAppName/$fileAppName".".xml",
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

  #
  # backup Components
  mkpath("$path/Projects/$fileProjectName/Applications/$fileAppName/Components");
  chmod(0777, "$path/Projects/$fileProjectName/Applications/$fileAppName/Components");

  my ($ok, $json) = InvokeCommander("SuppressLog", "getComponents", $pName, {applicationName => $appName});
  foreach my $comp ($json->findnodes("//component")) {
    my $compName=$comp->{'componentName'};
    my $fileCompName=safeFilename($compName);

    my ($success, $res, $errMsg, $errCode) = 
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Applications/$fileAppName/Components/$fileCompName".".xml",
          { 'path'=> "/projects/$pName/applications/$appName/components/$compName", 
                                        'relocatable' => 1,
                                        'withAcls'    => 1,
                                        'withNotifiers'=>1});
  
  if (! $success) {
    printf("  Error exporting component %s in application", $compName, $appName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  }
  else {
    $compCount++;
  }

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


$ec->setProperty("preSummary", "$appCount applications exported\n  $envCount environments exported\n  $compCount components exported");
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]







