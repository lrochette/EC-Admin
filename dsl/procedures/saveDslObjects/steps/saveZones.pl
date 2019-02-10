#############################################################################
#
#  Copyright 2015-2016 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

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
my $zoneCount=0;

# Get list of Zones
my ($success, $xPath) = InvokeCommander("SuppressLog", "getZones");

# Create the Zones directory
mkpath("$path/zones");
chmod(0777, "$path/zones");

foreach my $node ($xPath->findnodes('//zone')) {
  my $zoneName=$node->{'zoneName'};

  # skip zones that don't fit the pattern
  next if ($zoneName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("Saving Zone: %s\n", $zoneName);
  my $fileZoneName=safeFilename($zoneName);

  my ($success, $res, $errMsg, $errCode) =
      saveDslFile("$path/zones/$fileZoneName".".groovy",
                  "/zones[$zoneName]", $includeACLs);
  if (! $success) {
    printf("  Error exporting %s", $zoneName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $zoneCount++;
  }
}
$ec->setProperty("preSummary", "$zoneCount Zones exported");
$ec->setProperty("/myJob/zoneExported", $zoneCount);
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]
$[/myProject/scripts/backup/saveDslFile]

$[/myProject/scripts/perlLibJSON]
