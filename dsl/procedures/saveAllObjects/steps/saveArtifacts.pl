#############################################################################
#
# Save Artifacts and ArtifactVersions in DSL or XML Format
#     (but not the artifact files themselves)
#
# Author: L.Rochette
#
# Copyright 2018-2019 Electric Cloud, Inc.
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
# 2018-Sep-05 lrochette Initial Version
# 2019-Feb-11 lrochette Foundation for merge DSL and XML export
# 2019-Feb 21 lrochette Changing paths to match EC-DslDeploy
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;

#
# Parameters
#
my $path             = '$[pathname]';
my $exportArtifacts  = "$[exportArtifacts]";
my $pattern          = '$[pattern]';
my $caseSensitive    = "i";
my $includeACLs      = "$[includeACLs]";
my $relocatable      = "$[relocatable]";
my $format           = '$[format]';

#
# Global
#
my $errorCount=0;
my $artCount=0;
my $avCount=0;

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

# Get list of Artifacts
my ($success, $xPath) = InvokeCommander("SuppressLog", "getArtifacts");

# Create the Projects directory
mkpath("$path/artifacts");
chmod(0777, "$path/artifacts") or die("Can't change permissions on $path/artifacts: $!");

foreach my $node ($xPath->findnodes('//artifact')) {
  my $artName=$node->{'artifactName'};

  # skip artifacts that don't fit the pattern
  next if ($artName !~ /$pattern/$[caseSensitive] );  # / just for the color

  printf("Saving Artifact: %s\n", $artName);

  my $fileArtifactName=safeFilename($artName);
  mkpath("$path/artifacts/$fileArtifactName");
  chmod(0777, "$path/artifacts/$fileArtifactName");

  my ($success, $res, $errMsg, $errCode) =
      backupObject($format, "$path/artifacts/$fileArtifactName/artifact",
  					"/artifacts[$artName]", $relocatable, $includeACLs, "false");
  if (! $success) {
    printf("  Error exporting artifact %s", $artName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $artCount++;
  }
  #
  # Save Artifact Versions
  #
  mkpath("$path/artifacts/$fileArtifactName/artifactVersions");
  chmod(0777, "$path/artifacts/$fileArtifactName/artifactVersions");

  my ($success, $xPath) = InvokeCommander("SuppressLog", "getArtifactVersions",
      {'artifactName' => $artName});
  foreach my $av ($xPath->findnodes('//artifactVersion')) {
    my $version=$av->{'version'};
    my $avName=$av->{'artifactVersionName'};
    my $fileVersion=safeFilename($version);
    printf("  Saving version: %s\n", $version);

 	  my ($success, $res, $errMsg, $errCode) =
      backupObject($format, "$path/artifacts/$fileArtifactName/artifactVersions/$fileVersion",
  					"/artifactVersions[$avName]", $relocatable, $includeACLs, "false");

    if (! $success) {
      printf("  Error exporting artifact version %s", $version);
      printf("  %s: %s\n", $errCode, $errMsg);
      $errorCount++;
    }
    else {
      $avCount++;
    }

  }   # AV loop
}     # Artifact loop
my $str="";
$str .= createExportString($artCount,  "artifact");
$str .= createExportString($avCount,  "artifact version");
$ec->setProperty("preSummary", $str);

$ec->setProperty("/myJob/artifactExported", $artCount);
$ec->setProperty("/myJob/avExported", $avCount);

exit($errorCount);

$[/myProject/scripts/perlBackupLib]
$[/myProject/scripts/perlLibJSON]
