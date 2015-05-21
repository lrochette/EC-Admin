#############################################################################
#
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

# Parameters
#
my $path='$[pathname]';

my $errorCount=0;
my $projCount=0;
my $procCount=0;
my $wkfCount=0;

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProjects");

# Create the Projects directory
mkpath("$path/Projects");
chmod(0777, "$path/Projects");

foreach my $node ($xPath->findnodes('//project')) {
  my $pName=$node->{'projectName'};
  my $pluginName=$node->{'pluginName',};

  # skip plugins  
  next if ($pluginName ne "");
  printf("Saving Project: %s\n", $pName);
  my $fileProjectName=safeFilename($pName);
  mkpath("$path/Projects/$fileProjectName");
  chmod(0777, "$path/Projects/$fileProjectName");
  
  my ($success, $res, $errMsg, $errCode) = 
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/$fileProjectName".".xml",
  					{ 'path'=> "/projects/".$pName, 
                                          'relocatable' => 1,
                                          'withAcls'    => 1,
                                          'withNotifiers'=>1});
  if (! $success) {
    printf("  Error exporting %s", $pName);
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
 
 	my ($success, $res, $errMsg, $errCode) = 
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Procedures/$fileProcedureName".".xml",
  					{ 'path'=> "/projects/$pName/procedures/$procName", 
                                          'relocatable' => 1,
                                          'withAcls'    => 1,
                                          'withNotifiers'=>1});
    
    if (! $success) {
      printf("  Error exporting %s", $procName);
      printf("  %s: %s\n", $errCode, $errMsg);
      $errorCount++;
    }
    else {
      $procCount++;
    }
  }

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
      InvokeCommander("SuppressLog", "export", "$path/Projects/$fileProjectName/Workflows/$fileWkfName".".xml",
  					{ 'path'=> "/projects/$pName/workflowDefinitions/$wkfName", 
                                          'relocatable' => 1,
                                          'withAcls'    => 1,
                                          'withNotifiers'=>1});
    
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


