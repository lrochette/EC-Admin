#############################################################################
#
#  Copyright 2013-2016 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

#
# Parameters
#
my $path        = '$[pathname]';
my $exportSteps = "$[exportSteps]";
my $pattern     = '$[pattern]';
my $caseSensitive = "i";
my $includeACLs="$[includeACLs]";

#
# Global
#
my $errorCount=0;
my $projCount=0;
my $procCount=0;
my $stepCount=0;
my $wkfCount=0;

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

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
  next if ($pName !~ /$pattern/$[caseSensitive] );  # / just for the color

  printf("Saving Project: %s\n", $pName);

  my $fileProjectName=safeFilename($pName);
  mkpath("$path/Projects/$fileProjectName");
  chmod(0777, "$path/Projects/$fileProjectName");

  my ($success, $res, $errMsg, $errCode) =
      saveDslFile("$path/Projects/$fileProjectName/$fileProjectName".".grooy",
  					"/projects[$pName]", $includeACLs);
  if (! $success) {
    printf("  Error exporting project %s", $pName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $projCount++;
  }
  #
  # Save procedures
  #
  mkpath("$path/Projects/$fileProjectName/Procedures");
  chmod(0777, "$path/Projects/$fileProjectName/Procedures");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getProcedures", $pName);
  foreach my $proc ($xPath->findnodes('//procedure')) {
    my $procName=$proc->{'procedureName'};
    my $fileProcedureName=safeFilename($procName);
    printf("  Saving Procedure: %s\n", $procName);

    mkpath("$path/Projects/$fileProjectName/Procedures/$fileProcedureName");
    chmod(0777, "$path/Projects/$fileProjectName/Procedures/$fileProcedureName");
 	my ($success, $res, $errMsg, $errCode) =
      saveDslFile( "$path/Projects/$fileProjectName/Procedures/$fileProcedureName/$fileProcedureName".".groovy",
  					"/projects[$pName]procedures[$procName]", $includeACLs);

    if (! $success) {
      printf("  Error exporting procedure %s", $procName);
      printf("  %s: %s\n", $errCode, $errMsg);
      $errorCount++;
    }
    else {
      $procCount++;
    }
    #
    # Save steps
    #
    if ($exportSteps) {
      mkpath("$path/Projects/$fileProjectName/Procedures/$fileProcedureName/Steps");
      chmod(0777, "$path/Projects/$fileProjectName/Procedures/$fileProcedureName/Steps");

      my($success, $stepNodes) = InvokeCommander("SuppressLog", "getSteps", $pName, $procName);
      foreach my $step ($stepNodes->findnodes('//step')) {
        my $stepName=$step->{'stepName'};
        my $fileStepName=safeFilename($stepName);
        printf("    Saving Step: %s\n", $stepName);

 	    my ($success, $res, $errMsg, $errCode) =
           saveDslFile("$path/Projects/$fileProjectName/Procedures/$fileProcedureName/Steps/$fileStepName".".groovy",
  					"/projects[$pName]procedures[$procName]steps[$stepName]",$includeACLs);

        if (! $success) {
          printf("  Error exporting step %s", $stepName);
          printf("  %s: %s\n", $errCode, $errMsg);
          $errorCount++;
        } else {
          $stepCount++;
        }

      }  # step loop

    } # fi stepExport
  }   # procedure loop

  #
  # Save workflow definitions
  #
  mkpath("$path/Projects/$fileProjectName/Workflows");
  chmod(0777, "$path/Projects/$fileProjectName/Workflows");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getWorkflowDefinitions", $pName);
  foreach my $proc ($xPath->findnodes('//workflowDefinition')) {
    my $wkfName=$proc->{'workflowDefinitionName'};
    my $fileWkfName=safeFilename($wkfName);
    printf("  Saving Workflow Definition: %s\n", $wkfName);

    my ($success, $res, $errMsg, $errCode) =
      saveDslFile("$path/Projects/$fileProjectName/Workflows/$fileWkfName".".groovy",
  					"/projects[$pName]workflowDefinitions[$wkfName]",$includeACLs);

    if (! $success) {
      printf("  Error exporting %s", $wkfName);
      printf("  %s: %s\n", $errCode, $errMsg);
      $errorCount++;
    }
    else {
      $wkfCount++;
    }
  }

}
$ec->setProperty("preSummary", "$projCount projects exported\n  $procCount procedures exported\n  $wkfCount workflows exported");
$ec->setProperty("/myJob/projectExported", $projCount);
$ec->setProperty("/myJob/procedureExported", $procCount);
$ec->setProperty("/myJob/workflowExported", $wkfCount);

exit($errorCount);

$[/myProject/scripts/backup/safeFilename]
$[/myProject/scripts/backup/saveDslFile]

$[/myProject/scripts/perlLibJSON]
