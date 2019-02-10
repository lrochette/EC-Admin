#############################################################################
#
#  Copyright 2015-2019 Electric-Cloud Inc.
#
#  Author: L. Rochette
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
my $includeNotifiers="$[includeNotifiers]";
my $relocatable="$[relocatable]";

#
# Global
#
my $errorCount=0;
my $tagCount=0;

# tags were introduced in 8.5
my $version=getVersion();
if (compareVersion($version, "8.5") < 0) {
  $ec->setProperty("Tags were introduced only 8.5");
  exit(0);
}

# Get list of Tags
my ($success, $xPath) = InvokeCommander("SuppressLog", "getTags");

# Create the Tags directory
mkpath("$path/Tags");
chmod(0777, "$path/Tags");

foreach my $node ($xPath->findnodes('//tag')) {
  my $tagName=$node->{'tagName'};

  # skip tags that don't fit the pattern
  next if ($tagName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("Saving Tag: %s\n", $tagName);
  my $fileTagName=safeFilename($tagName);

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Tags/$fileTagName".".xml",
  { 'path'=> "/tags[$tagName]",
    'relocatable' => $relocatable,
    'withAcls'    => $includeACLs,
    'withNotifiers'=>$includeNotifiers});
  if (! $success) {
    printf("  Error exporting %s", $tagName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $tagCount++;
  }
}
$ec->setProperty("preSummary", "$tagCount Tags exported");
$ec->setProperty("/myJob/tagExported", $tagCount);
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]
