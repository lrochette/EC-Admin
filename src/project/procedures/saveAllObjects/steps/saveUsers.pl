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
my $userCount=0;

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getUsers", {maximum=>5000});

# Create the Resources directory
mkpath("$path/Users");
chmod(0777, "$path/Users");

foreach my $node ($xPath->findnodes('//user')) {
  my $userName=$node->{'userName'};

  printf("Saving User: %s\n", $userName);
  my $fileUserName=safeFilename($userName); 
  
  my ($success, $res, $errMsg, $errCode) = 
      InvokeCommander("SuppressLog", "export", "$path/Users/$fileUserName".".xml",
  					{ 'path'=> "/users/".$userName, 
                                          'relocatable' => 1,
                                          'withAcls'    => 1});
  if (! $success) {
    printf("  Error exporting %s", $userName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $userCount++;
  }
}
$ec->setProperty("preSummary", "$userCount users exported");
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]











