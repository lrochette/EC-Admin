#############################################################################
#
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

# Parameters
#
my $path="$[pathname]";

my $errorCount=0;
my $resCount=0;

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getResources");

# Create the Resources directory
mkpath("$path/Resources");
chmod(0777, "$path/Resources");

foreach my $node ($xPath->findnodes('//resource')) {
  my $resName=$node->{'resourceName'};

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


