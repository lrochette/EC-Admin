#############################################################################
#
#  Copyright 2015-2016 Electric-Cloud Inc.
#
# Script to backup the Deploy objects (application, environment, components)
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

#
# Parameters
#
my $path    = '$[pathname]';
my $pattern = '$[pattern]';

#
# Global
#
my $errorCount = 0;
my $appCount   = 0;
my $envCount   = 0;
my $compCount  = 0;
my $pipeCount  = 0;
my $relCount   = 0;

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

  # skip applications that don't fit the pattern
  next if ($appName !~ /$pattern/$[caseSensitive] );

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
    printf("  Error exporting application %s", $appName);
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
# Save Environments definitions
#
mkpath("$path/Projects/$fileProjectName/Environments");
chmod(0777, "$path/Projects/$fileProjectName/Environments");

my ($success, $xPath) = InvokeCommander("SuppressLog", "getEnvironments", $pName);
foreach my $proc ($xPath->findnodes('//environment')) {
  my $envName=$proc->{'environmentName'};

  # skip environments that don't fit the pattern
  next if ($envName !~ /$pattern/$[caseSensitive] );

  my $fileEnvName=safeFilename($envName);
  printf("  Saving Environment Definition: %s\n", $envName);

  my ($success, $res, $errMsg, $errCode) =
    InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Environments/$fileEnvName".".xml",
          { 'path'=> "/projects/$pName/environments/$envName",
                                        'relocatable' => 1,
                                        'withAcls'    => 1,
                                        'withNotifiers'=>1});

  if (! $success) {
    printf("  Error exporting environment %s", $envName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  }
  else {
    $envCount++;
  }
}

#
# Export pipelines if the version is recent enough
#
if (compareVersion($version, "6.0") < 0) {
  printf("WARNING: Version 6.0 or greater is required to save Pipeline objects");
} else {
  # Save pipeline definitions
  #
  mkpath("$path/Projects/$fileProjectName/Pipelines");
  chmod(0777, "$path/Projects/$fileProjectName/Pipelines");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getPipelines", $pName);
  foreach my $proc ($xPath->findnodes('//pipeline')) {
    my $pipeName=$proc->{'pipelineName'};

    # skip pipelines that don't fit the pattern
    next if ($pipeName !~ /$pattern/$[caseSensitive] );

    my $filePipeName=safeFilename($pipeName);
    printf("  Saving Pipeline Definition: %s\n", $pipeName);

    my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Pipelines/$filePipeName".".xml",
            { 'path'=> "/projects/$pName/pipelines/$pipeName",
                                          'relocatable' => 1,
                                          'withAcls'    => 1,
                                          'withNotifiers'=>1});

    if (! $success) {
      printf("  Error exporting pipeline %s", $pipeName);
      printf("  %s: %s\n", $errCode, $errMsg);
      $errorCount++;
    }
    else {
      $pipeCount++;
    }
  }         # Pipeline loop
}           # Version greater than 6.0


# Export releases if the version is recent enough
#
if (compareVersion($version, "6.1") < 0) {
  printf("WARNING: Version 6.1 or greater is required to save Release objects");
} else {
  # Save release definitions
  #
  mkpath("$path/Projects/$fileProjectName/Releases");
  chmod(0777, "$path/Projects/$fileProjectName/Releases");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getReleases", $pName);
  foreach my $proc ($xPath->findnodes('//release')) {
    my $relName=$proc->{'releaseName'};

    # skip releases that don't fit the pattern
    next if ($relName !~ /$pattern/$[caseSensitive] );

    my $filePipeName=safeFilename($relName);
    printf("  Saving Release Definition: %s\n", $relName);

    my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Releases/$filePipeName".".xml",
            { 'path'=> "/projects[$pName]releases[$relName]",
                                          'relocatable' => 1,
                                          'withAcls'    => 1,
                                          'withNotifiers'=>1});

    if (! $success) {
      printf("  Error exporting release %s", $relName);
      printf("  %s: %s\n", $errCode, $errMsg);
      $errorCount++;
    }
    else {
      $relCount++;
    }
  }         # Release loop
}           # Version greater than 6.1

my $str=sprintf("$appCount applications exported\n" );
$str .= sprintf("   $envCount environments exported\n");
$str .= sprintf("   $compCount components exported\n");
$str .= sprintf("   $pipeCount pipelines exported\n");
$str .= sprintf("   $relCount releases exported\n");


$ec->setProperty("preSummary", $str);
$ec->setProperty("/myJob/papplicationExported", $appCount);
$ec->setProperty("/myJob/environmentExported",  $envCount);
$ec->setProperty("/myJob/componentExported",    $compCount);
$ec->setProperty("/myJob/pipelineExported",     $pipeCount);
$ec->setProperty("/myJob/releaseExported",      $relCount);
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]


