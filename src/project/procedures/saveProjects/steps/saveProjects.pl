#############################################################################
#
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeader]

#
# Parameters
#
my $path="$[pathname]";
my $includeACLs="$[includeACLs]";
my $includeNotifiers="$[includeNotifiers]";
my $relocatable="$[relocatable]";

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

my $errorCount=0;
# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProjects");

# Create the directory
# chmod required for cases when the server agent user and the server user 
# are different and the mask prevent the created directory to be written
# by the latter.
mkpath($path);
chmod 0777, $path;

my $nodeset = $xPath->find('//project');
foreach my $node ($nodeset->get_nodelist) {
  my $pName=$xPath->findvalue('projectName', $node);
  my $pluginName=$xPath->findvalue('pluginName', $node);

  # skip plugins  
  next if ($pluginName ne "");
  printf("Saving Project: %s\n", $pName);
  my ($success, $xPath, $errMsg, $errCode) = InvokeCommander("SuppressLog", "export", $path."/$pName".".xml",
  					{ 'path'=> "/projects/".$pName, 
                                          'relocatable' => $relocatable,
                                          'withAcls'    => $includeACLs,
                                          'withNotifiers'=>$includeNotifiers});
  if (! $success) {
    printf("  Error exporting %s", $pName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  }
}
exit($errorCount);

$[/myProject/scripts/perlLib]


















