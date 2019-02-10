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
my $includeACLs="$[includeACLs]";

#
# Global
#
my $errorCount=0;
my $resCount=0;

# Get list of resources
my ($success, $xPath) = InvokeCommander("SuppressLog", "getResources");

# Create the Resources directory
mkpath("$path/resources");
chmod(0777, "$path/resources");

foreach my $node ($xPath->findnodes('//resource')) {
  my $resName=$node->{'resourceName'};

  # skip resources that don't fit the pattern
  next if ($resName !~ /$pattern/$[caseSensitive] );  # / for color mode

  printf("Saving Resource: %s\n", $resName);
  my $fileResourceName=safeFilename($resName);

  my ($success, $res, $errMsg, $errCode) =
      saveDslFile("$path/resources/$fileResourceName".".groovy",
        "/resources[$resName]", $includeACLs);
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
$[/myProject/scripts/backup/saveDslFile]

$[/myProject/scripts/perlLibJSON]
