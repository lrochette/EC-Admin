#############################################################################
#
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

# Parameters
#
my $path='$[pathname]';

my $errorCount=0;
my $wksCount=0;

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getWorkspaces");

# Create the Workspaces directory
mkpath("$path/Workspaces");
chmod(0777, "$path/Workspaces");

foreach my $node ($xPath->findnodes('//workspace')) {
  my $resName=$node->{'workspaceName'};

  printf("Saving Workspace: %s\n", $resName);
  my $fileWorkspaceName=safeFilename($resName); 
  
  my ($success, $res, $errMsg, $errCode) = 
      InvokeCommander("SuppressLog", "export", "$path/Workspaces/$fileWorkspaceName".".xml",
  					{ 'path'=> "/workspaces/".$resName, 
                                          'relocatable' => 1,
                                          'withAcls'    => 1});
  if (! $success) {
    printf("  Error exporting %s", $resName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $wksCount++;
  }
}
$ec->setProperty("preSummary", "$wksCount workspaces exported");
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]





