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
my $gateCount=0;

# Get list of gateways
my ($success, $xPath) = InvokeCommander("SuppressLog", "getGateways");

# Create the Gateways directory
mkpath("$path/Gateways");
chmod(0777, "$path/Gateways");

foreach my $node ($xPath->findnodes('//gateway')) {
  my $gateName=$node->{'gatewayName'};

  # skip gateways that don't fit the pattern
  next if ($gateName !~ /$pattern/$[caseSensitive] );

  printf("Saving Gateway: %s\n", $gateName);
  my $fileGatewayName=safeFilename($gateName);

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Gateways/$fileGatewayName".".xml",
  { 'path'=> "/gateways/".$gateName,
                                          'relocatable' => 1,
                                          'withAcls'    => 1});
  if (! $success) {
    printf("  Error exporting %s", $gateName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $gateCount++;
  }
}
$ec->setProperty("preSummary", "$gateCount Gateways exported");
$ec->setProperty("/myJob/gatewayExported", $gateCount);
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]

