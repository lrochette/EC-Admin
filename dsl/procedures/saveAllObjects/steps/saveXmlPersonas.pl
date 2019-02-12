#############################################################################
#
#  Save Personas and tied objects (in DSL or XML)
#
#  Author: L.Rochette
#
#  Copyright 2015-2019 Electric-Cloud Inc.
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
# 2019-Feb-11 lrochette Foundation for merge DSL and XML export
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

#
# Parameters
#
my $path             = '$[pathname]';
my $pattern          = '$[pattern]';
my $includeACLs      = "$[includeACLs]";
my $includeNotifiers = "$[includeNotifiers]";
my $relocatable      = "$[relocatable]";
my $format           = '$[format]';

#
# Global
#
my $errorCount=0;
my $personaCount=0;
my $personaPageCount=0;
my $personaCategoryCount=0;

# personas were introduced in 9.0
my $version=getVersion();
if (compareVersion($version, "9.0") < 0) {
  $ec->setProperty("summary", "Personas were introduced only in 9.0");
  exit(0);
}

#
# Persona
#

# Get list of Personas
my ($success, $xPath) = InvokeCommander("SuppressLog", "getPersonas");

# Create the Personas directory
mkpath("$path/Personas");
chmod(0777, "$path/Personas");
printf("Saving Personas:\n");
printf("----------------\n");

foreach my $node ($xPath->findnodes('//persona')) {
  my $personaName=$node->{'personaName'};

  # skip personas that don't fit the pattern
  next if ($personaName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("  Saving Persona: %s\n", $personaName);
  my $filePersonaName=safeFilename($personaName);

  my ($success, $res, $errMsg, $errCode) =
    backupObject($format, "$path/Personas/$filePersonaName",
    "/personas[$personaName]", $relocatable, $includeACLs, $includeNotifiers);
  if (! $success) {
    printf("    Error exporting %s", $personaName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $personaCount++;
  }
}

#
# Persona Pages
#

# Get list of Persona Pages
($success, $xPath) = InvokeCommander("SuppressLog", "getPersonaPages");

# Create the Persona Pages directory
mkpath("$path/PersonaPages");
chmod(0777, "$path/PersonaPages");
printf("\nSaving PersonaPages:\n");
printf("--------------------\n");

foreach my $node ($xPath->findnodes('//personaPage')) {
  my $personaPageName=$node->{'personaPageName'};

  # skip personaPages that don't fit the pattern
  next if ($personaPageName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("  Saving PersonaPage: %s\n", $personaPageName);
  my $filePersonaPageName=safeFilename($personaPageName);

  my ($success, $res, $errMsg, $errCode) =
    backupObject($format, "$path/PersonaPages/$filePersonaPageName",
    "/personaPages[$personaPageName]", $relocatable, $includeACLs, $includeNotifiers);
  if (! $success) {
    printf("    Error exporting %s", $personaPageName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $personaPageCount++;
  }
}

#
# Persona Categories
#

# Get list of Persona Categories
($success, $xPath) = InvokeCommander("SuppressLog", "getPersonaCategories");

# Create the Persona Categories directory
mkpath("$path/PersonaCategories");
chmod(0777, "$path/PersonaCategories");
printf("\nSaving PersonaCategories:\n");
printf("--------------------\n");

foreach my $node ($xPath->findnodes('//personaCategory')) {
  my $personaCategoryName=$node->{'personaCategoryName'};

  # skip personaCategories that don't fit the pattern
  next if ($personaCategoryName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("  Saving PersonaCategory: %s\n", $personaCategoryName);
  my $filePersonaCategoryName=safeFilename($personaCategoryName);

  my ($success, $res, $errMsg, $errCode) =
    backupObject($format, "$path/PersonaCategories/$filePersonaCategoryName",
    "/personaCategories[$personaCategoryName]", $relocatable, $includeACLs, $includeNotifiers);
  if (! $success) {
    printf("    Error exporting %s", $personaCategoryName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $personaCategoryCount++;
  }
}

$ec->setProperty("preSummary", "$personaCount Personas exported\n" .
  "$personaPageCount Persona Pages exported\n" .
  "$personaCategoryCount Persona Categories exported");
$ec->setProperty("/myJob/personaExported", $personaCount);
$ec->setProperty("/myJob/personaPageExported", $personaPageCount);
$ec->setProperty("/myJob/personaCategoryExported", $personaCategoryCount);
exit($errorCount);

$[/myProject/scripts/perlBackupLib]
$[/myProject/scripts/perlLibJSON]
