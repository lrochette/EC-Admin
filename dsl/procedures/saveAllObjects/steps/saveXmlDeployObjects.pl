#############################################################################
#
#  Copyright 2015-2019 Electric-Cloud Inc.
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
my $includeACLs="$[includeACLs]";
my $includeNotifiers="$[includeNotifiers]";
my $relocatable="$[relocatable]";

#
# Global
#
my $version=getVersion();
my $errorCount = 0;
my $appCount   = 0;
my $envCount   = 0;
my $compCount  = 0;
my $pipeCount  = 0;
my $relCount   = 0;
my $servCount  = 0;

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

#
# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProjects");

# Create the Projects directory
mkpath("$path/Projects");
chmod(0777, "$path/Projects") or die("Can't change permissions on $path/Projects: $!");

foreach my $node ($xPath->findnodes('//project')) {
  my $pName=$node->{'projectName'};
  my $pluginName=$node->{'pluginName',};

  # skip plugins
  next if ($pluginName ne "");

  # skip projects that don't fit the pattern
  next if ($pName !~ /$pattern/$[caseSensitive] ); # / just for the color

  # skip non Default project for version before 6.2
  next if (($pName ne "Default") && ($version < "6.2"));
  printf("Saving Project: %s\n", $pName);

  my $fileProjectName=safeFilename($pName);
  #
  # Save Applications
  #
  mkpath("$path/Projects/$fileProjectName/Applications");
  chmod(0777, "$path/Projects/$fileProjectName/Applications");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getApplications", $pName);
  foreach my $app ($xPath->findnodes('//application')) {
    my $appName=$app->{'applicationName'};

    # skip applications that don't fit the pattern
    next if (($pName  eq "Default") && ($appName !~ /$pattern/$[caseSensitive] )); # / just for the color

    my $fileAppName=safeFilename($appName);
    printf("  Saving Application: %s\n", $appName);

    mkpath("$path/Projects/$fileProjectName/Applications/$fileAppName");
    chmod(0777, "$path/Projects/$fileProjectName/Applications/$fileAppName");
    my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Applications/$fileAppName/$fileAppName".".xml",
            { 'path'=> "/projects[$pName]applications[$appName]",
              'relocatable' => $relocatable,
              'withAcls'    => $includeACLs,
              'withNotifiers'=>$includeNotifiers});

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
      printf("    Saving Component: %s\n", $compName);

      my ($success, $res, $errMsg, $errCode) =
        InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Applications/$fileAppName/Components/$fileCompName".".xml",
            { 'path'=> "/projects[$pName]applications[$appName]components[$compName]",
              'relocatable' => $relocatable,
              'withAcls'    => $includeACLs,
              'withNotifiers'=>$includeNotifiers});

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
    next if (($pName  eq "Default") && ($envName !~ /$pattern/$[caseSensitive] ));  # / just for the color

    my $fileEnvName=safeFilename($envName);
    printf("  Saving Environment: %s\n", $envName);

    my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Environments/$fileEnvName".".xml",
            { 'path'=> "/projects[$pName]environments[$envName]",
              'relocatable' => $relocatable,
              'withAcls'    => $includeACLs,
              'withNotifiers'=>$includeNotifiers});

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
      next if (($pName  eq "Default") && ($pipeName !~ /$pattern/$[caseSensitive] )); # / just for the color

      my $filePipeName=safeFilename($pipeName);
      printf("  Saving Pipeline: %s\n", $pipeName);

      my ($success, $res, $errMsg, $errCode) =
        InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Pipelines/$filePipeName".".xml",
              { 'path'=> "/projects[$pName]pipelines[$pipeName]",
                'relocatable' => $relocatable,
                'withAcls'    => $includeACLs,
                'withNotifiers'=>$includeNotifiers});

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
      next if (($pName  eq "Default") && ($relName !~ /$pattern/$[caseSensitive] ));  # / just for the color

      my $filePipeName=safeFilename($relName);
      printf("  Saving Release: %s\n", $relName);

      my ($success, $res, $errMsg, $errCode) =
        InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Releases/$filePipeName".".xml",
              { 'path'=> "/projects[$pName]releases[$relName]",
                'relocatable' => $relocatable,
                'withAcls'    => $includeACLs,
                'withNotifiers'=>$includeNotifiers});

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

  # Export services if the version is recent enough
  #
  if (compareVersion($version, "8.1") < 0) {
    printf("WARNING: Version 8.1 or greater is required to save Services objects");
  } else {
    # Save release definitions
    #
    mkpath("$path/Projects/$fileProjectName/Services");
    chmod(0777, "$path/Projects/$fileProjectName/Services");

    my ($success, $xPath) = InvokeCommander("SuppressLog", "getServices", $pName);
    foreach my $proc ($xPath->findnodes('//service')) {
      my $servName=$proc->{'serviceName'};

      # skip services that don't fit the pattern
      next if (($pName  eq "Default") && ($servName !~ /$pattern/$[caseSensitive] ));  # / just for the color

      my $fileServName=safeFilename($servName);
      printf("  Saving Service: %s\n", $servName);

      my ($success, $res, $errMsg, $errCode) =
        InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Services/$fileServName".".xml",
              { 'path'=> "/projects[$pName]services[$servName]",
                'relocatable' => $relocatable,
                'withAcls'    => $includeACLs,
                'withNotifiers'=>$includeNotifiers});

      if (! $success) {
        printf("  Error exporting service %s", $servName);
        printf("  %s: %s\n", $errCode, $errMsg);
        $errorCount++;
      }
      else {
        $servCount++;
      }
    }         # Release loop
  }           # Version greater than 8.1
}             # project loop

my $str=sprintf("   $appCount applications exported\n" );
$str .= sprintf("   $envCount environments exported\n");
$str .= sprintf("   $compCount components exported\n");
$str .= sprintf("   $pipeCount pipelines exported\n");
$str .= sprintf("   $relCount releases exported\n");
$str .= sprintf("   $servCount services exported\n");

$ec->setProperty("preSummary", $str);
$ec->setProperty("/myJob/papplicationExported", $appCount);
$ec->setProperty("/myJob/environmentExported",  $envCount);
$ec->setProperty("/myJob/componentExported",    $compCount);
$ec->setProperty("/myJob/pipelineExported",     $pipeCount);
$ec->setProperty("/myJob/releaseExported",      $relCount);
$ec->setProperty("/myJob/serviceExported",      $servCount);
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]
