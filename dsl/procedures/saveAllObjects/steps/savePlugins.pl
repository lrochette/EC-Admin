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
my $path        = '$[pathname]';
my $exportSteps = "$[exportSteps]";
my $pattern     = '$[pattern]';
my $caseSensitive = "i";
my $includeACLs   = "$[includeACLs]";
my $includeNotifiers = "$[includeNotifiers]";
my $relocatable      = "$[relocatable]";

#
# Global
#
my $errorCount=0;
my $projCount=0;
my $procCount=0;
my $stepCount=0;
my $wkfCount=0;

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

# Get list of Plugins
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProjects");

# Create the Plugins directory
mkpath("$path/Plugins");
chmod(0777, "$path/Plugins") or die("Can't change permissions on $path/Plugins: $!");

foreach my $node ($xPath->findnodes('//project')) {
  my $pName=$node->{'projectName'};
  my $pluginName=$node->{'pluginName',};

  # skip plugins
  next if ($pluginName eq "");

  # skip Plugins that don't fit the pattern
  next if ($pName !~ /$pattern/$[caseSensitive] );  # / just for the color

  printf("Saving Plugin: %s\n", $pName);

  my $fileProjectName=safeFilename($pName);
  mkpath("$path/Plugins/$fileProjectName");
  chmod(0777, "$path/Plugins/$fileProjectName");

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Plugins/$fileProjectName/$fileProjectName".".xml",
  					{ 'path'          => "/projects[$pName]",
              'relocatable' => $relocatable,
              'withAcls'    => $includeACLs,
              'withNotifiers'=>$includeNotifiers});
  if (! $success) {
    printf("  Error exporting plugin %s", $pName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $projCount++;
  }

}
$ec->setProperty("preSummary", "$projCount plugins exported");
$ec->setProperty("/myJob/pluginExported", $projCount);

exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]
