#############################################################################
#
# Save top server properties (as /server export is the whole thing)
#
# Author: L.Rochette
#
#  Copyright 2018 Electric-Cloud Inc.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
# History
# ---------------------------------------------------------------------------
# 2018-11-07 lrochette Initial Version
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

#
# Parameters
#
my $path        = '$[pathname]';
my $pattern     = '$[pattern]';
my $caseSensitive = "i";
my $includeACLs="$[includeACLs]";

#
# Global
#
my $errorCount=0;
my $propCount=0;

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

# Get list of Server properties
my ($success, $xPath) = InvokeCommander("SuppressLog",
  "getProperties",
  {path => "/server"});

# Create the /Server/Properties directory
mkpath("$path/Server/Properties");
chmod(0777, "$path/Server") or die("Can't change permissions on $path/Server: $!");
chmod(0777, "$path/Server/Properties") or die("Can't change permissions on $path/Server/Properties: $!");

foreach my $node ($xPath->findnodes('//property')) {
  my $pName=$node->{'propertyName'};
  my $filePropName=safeFilename($pName);

  my ($success, $res, $errMsg, $errCode) =
     saveDslFile("$path/Server/Properties/${filePropName}.groovy",
                 "/server[$pName]", $includeACLs);
  if (! $success) {
    printf("  Error exporting property %s", $pName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $propCount++;
  }
}

$ec->setProperty("preSummary", "$propCount server properties exported");
$ec->setProperty("/myJob/serverPropertiesExported", $propCount);

exit($errorCount);

$[/myProject/scripts/backup/safeFilename]
$[/myProject/scripts/backup/saveDslFile]

$[/myProject/scripts/perlLibJSON]
