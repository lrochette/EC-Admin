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
my $poolCount=0;

# Get list of resource pools
my ($success, $xPath) = InvokeCommander("SuppressLog", "getResourcePools");

# Create the Resources directory
mkpath("$path/resourcePools");
chmod(0777, "$path/resourcePools");

foreach my $node ($xPath->findnodes('//resourcePool')) {
  my $poolName=$node->{'resourcePoolName'};

  # skip pools that don't fit the pattern
  next if ($poolName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("Saving Resource Pool: %s\n", $poolName);
  my $filePoolName=safeFilename($poolName);

  my ($success, $res, $errMsg, $errCode) =
      saveDslFile("$path/resourcePools/$filePoolName".".groovy",
  					"/resourcePools/[$poolName]", $includeACLs);
  if (! $success) {
    printf("  Error exporting %s", $poolName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
	$poolCount++;
  }
}

$ec->setProperty("preSummary", "$poolCount pools exported");
$ec->setProperty("/myJob/poolExported", $poolCount);
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]
$[/myProject/scripts/backup/saveDslFile]

$[/myProject/scripts/perlLibJSON]
