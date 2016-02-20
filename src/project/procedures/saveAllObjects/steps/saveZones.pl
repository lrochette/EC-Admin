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

#
# Global
#
my $errorCount=0;
my $zoneCount=0;

# Get list of Zones
my ($success, $xPath) = InvokeCommander("SuppressLog", "getZones");

# Create the Zones directory
mkpath("$path/Zones");
chmod(0777, "$path/Zones");

foreach my $node ($xPath->findnodes('//zone')) {
  my $zoneName=$node->{'zoneName'};

  # skip zones that don't fit the pattern
  next if ($zoneName !~ /$pattern/ );

  printf("Saving Zone: %s\n", $zoneName);
  my $fileZoneName=safeFilename($zoneName);

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Zones/$fileZoneName".".xml",
  { 'path'=> "/zones/".$zoneName,
                                          'relocatable' => 1,
                                          'withAcls'    => 1});
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

$[/myProject/scripts/perlLibJSON]

