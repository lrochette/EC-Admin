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
my $poolCount=0;

# Get list of resource pools
my ($success, $xPath) = InvokeCommander("SuppressLog", "getResourcePools");

# Create the Resources directory
mkpath("$path/Pools");
chmod(0777, "$path/Pools");

foreach my $node ($xPath->findnodes('//resourcePool')) {
  my $poolName=$node->{'resourcePoolName'};

  # skip pools that don't fit the pattern
  next if ($poolName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("Saving Resource Pool: %s\n", $poolName);
  my $filePoolName=safeFilename($poolName);

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Pools/$filePoolName".".xml",
  					{ 'path'=> "/resourcePools/[$poolName]",
              'relocatable' => 1,
              'withAcls'    => 1});
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

$[/myProject/scripts/perlLibJSON]


