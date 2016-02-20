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
my $path    = '$[pathname]';
my $pattern = '$[pattern]';

#
# Global
#
my $errorCount=0;
my $resCount=0;

# Get list of resources
my ($success, $xPath) = InvokeCommander("SuppressLog", "getResources");

# Create the Resources directory
mkpath("$path/Resources");
chmod(0777, "$path/Resources");

foreach my $node ($xPath->findnodes('//resource')) {
  my $resName=$node->{'resourceName'};

  # skip resources that don't fit the pattern
  next if ($resName !~ /$pattern/ );

  printf("Saving Resource: %s\n", $resName);
  my $fileResourceName=safeFilename($resName);

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Resources/$fileResourceName".".xml",
  					{ 'path'=> "/resources/".$resName,
                                          'relocatable' => 1,
                                          'withAcls'    => 1});
  if (! $success) {
    printf("  Error exporting %s", $resName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $resCount++;
  }
}
$ec->setProperty("preSummary", "$resCount resources exported");
$ec->setProperty("/myJob/resourceExported", $resCount);

exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]

