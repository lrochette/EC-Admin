#############################################################################
#
#  Copyright 2015 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

# Parameters
#
my $path='$[pathname]';

my $errorCount=0;
my $zoneCount=0;

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getZones");

# Create the Zones directory
mkpath("$path/Zones");
chmod(0777, "$path/Zones");

foreach my $node ($xPath->findnodes('//zone')) {
  my $zoneName=$node->{'zoneName'};

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












