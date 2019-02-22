#############################################################################
#
#  Copyright 2013-2016 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

#
# Parameters
#
my $path        = '$[pathname]';
my $pattern     = '$[pattern]';

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
mkpath("$path/projects");
chmod(0777, "$path/projects") or die("Can't change permissions on $path/projects: $!");

foreach my $node ($xPath->findnodes('//project')) {
  my $pName=$node->{'projectName'};
  my $pluginName=$node->{'pluginName',};

  # skip plugins
  next if ($pluginName ne "");

  # skip projects that don't fit the pattern
  next if ($pName !~ /$pattern/ );

  printf("Saving Project: %s\n", $pName);

  my $fileProjectName=safeFilename($pName);
  mkpath("$path/projects/$fileProjectName");
  chmod(0777, "$path/projects/$fileProjectName");

  my ($success, $res, $errMsg, $errCode) =
      backupObject("DSL", "$path/projects/$fileProjectName/project",
  					"/projects[$pName]", "true", "true", "true");
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
  mkpath("$path/projects/$fileProjectName/procedures");
  chmod(0777, "$path/projects/$fileProjectName/procedures");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getProcedures", $pName);
  foreach my $proc ($xPath->findnodes('//procedure')) {
    my $procName=$proc->{'procedureName'};
    my $fileProcedureName=safeFilename($procName);
    printf("  Saving Procedure: %s\n", $procName);

    mkpath("$path/projects/$fileProjectName/procedures/$fileProcedureName");
    chmod(0777, "$path/projects/$fileProjectName/procedures/$fileProcedureName");
 	my ($success, $res, $errMsg, $errCode) =
    backupObject("DSL",
      "$path/projects/$fileProjectName/procedures/$fileProcedureName/procedure",
  		"/projects[$pName]procedures[$procName]", "true", "true", "true");

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
    mkpath("$path/projects/$fileProjectName/procedures/$fileProcedureName/steps");
    chmod(0777, "$path/projects/$fileProjectName/procedures/$fileProcedureName/steps");

    my($success, $stepNodes) = InvokeCommander("SuppressLog", "getSteps", $pName, $procName);
    foreach my $step ($stepNodes->findnodes('//step')) {
      my $stepName=$step->{'stepName'};
      my $fileStepName=safeFilename($stepName);
      printf("    Saving Step: %s\n", $stepName);

      my $shell=$ec->getProperty("/projects[$pName]procedures[$procName]steps[$stepName]/shell")->findvalue("//value");
      my $stepExt='.sh';
      $stepExt=".pl" if ($shell =~ /perl/);
      $stepExt=".groovy" if (($shell =~ /dsl/i) || ($shell =~ /groovy/));
      $stepExt=".ps1" if ($shell =~ /powershell/i);
      my $cmd=$ec->getProperty("/projects[$pName]procedures[$procName]steps[$stepName]/command",
                        {expand=>'0'}
                  )->findvalue("//value");
      if (! open(my $CMD, "> $path/projects/$fileProjectName/procedures/$fileProcedureName/steps/$fileStepName$stepExt")) {
        printf("  Error exporting step '%s' command", $stepName);
        $errorCount++;
      } else {
        print $CMD $cmd;
        close($CMD);
      }
    }  # step loop
    printf("\n");
  }   # procedure loop

  #
  # Save workflow definitions
  #
  mkpath("$path/projects/$fileProjectName/workflows");
  chmod(0777, "$path/projects/$fileProjectName/workflows");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getWorkflowDefinitions", $pName);
  foreach my $proc ($xPath->findnodes('//workflowDefinition')) {
    my $wkfName=$proc->{'workflowDefinitionName'};
    my $fileWkfName=safeFilename($wkfName);
    printf("  Saving Workflow Definition: %s\n", $wkfName);

    my ($success, $res, $errMsg, $errCode) =
      backupObject("DSL", "$path/projects/$fileProjectName/workflows/workflow",
				"/projects[$pName]workflowDefinitions[$wkfName]",
        "true", "true", "true");

    if (! $success) {
      printf("  Error exporting %s", $wkfName);
      printf("  %s: %s\n", $errCode, $errMsg);
      $errorCount++;
    }
    else {
      $wkfCount++;
    }
    printf("\n");

  }
  printf("\n");

}
$ec->setProperty("preSummary", " $projCount projects exported\n $procCount procedures exported\n $wkfCount workflows exported");
$ec->setProperty("/myJob/projectExported", $projCount);
$ec->setProperty("/myJob/procedureExported", $procCount);
$ec->setProperty("/myJob/workflowExported", $wkfCount);

exit($errorCount);

$[/myProject/scripts/perlBackupLib]
$[/myProject/scripts/perlLibJSON]
