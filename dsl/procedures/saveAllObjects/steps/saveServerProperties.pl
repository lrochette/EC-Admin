#############################################################################
#
# Save top server properties (as /server export is the whole thing)
#   DSL or XML format
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
# 2019-02-11 lrochette Foundation for merge DSL and XML export
# 2019-Feb 21 lrochette Changing paths to match EC-DslDeploy
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

#
# Parameters
#
my $path          = '$[pathname]';
my $pattern       = '$[pattern]';
my $caseSensitive = "i";
my $includeACLs   = "$[includeACLs]";
my $relocatable   = "$[relocatable]";
my $format        = '$[format]';

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

# Create the /server/properties directory
mkpath("$path/server/properties");
chmod(0777, "$path/server") or die("Can't change permissions on $path/server: $!");
chmod(0777, "$path/server/properties") or die("Can't change permissions on $path/server/properties: $!");

foreach my $node ($xPath->findnodes('//property')) {
  my $pName=$node->{'propertyName'};
  my $filePropName=safeFilename($pName);

  my ($success, $res, $errMsg, $errCode) =
     backupObject($format, "$path/server/properties/${filePropName}",
       "/server[$pName]", "false", $includeACLs, "false");
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

$[/myProject/scripts/perlBackupLib]
$[/myProject/scripts/perlLibJSON]
