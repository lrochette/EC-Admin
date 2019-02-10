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

#
# Global
#
my $errorCount=0;
my $personaCount=0;
my $personaPageCount=0;

# personas were introduced in 8.5
my $version=getVersion();
if (compareVersion($version, "9.0") < 0) {
  $ec->setProperty("Personas were introduced only 9.0");
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
printf("\nSaving Personas:\n");
printf("--------------------\n");

foreach my $node ($xPath->findnodes('//persona')) {
  my $personaName=$node->{'personaName'};

  # skip personas that don't fit the pattern
  next if ($personaName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("  Saving Persona: %s\n", $personaName);
  my $filePersonaName=safeFilename($personaName);

  my ($success, $res, $errMsg, $errCode) =
      saveDslFile("$path/Personas/$filePersonaName".".groovy",
                  "/personas[$personaName]", $includeACLs);
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
      saveDslFile("$path/PersonaPages/$filePersonaPageName".".xml",
        "/personaPages[$personaPageName]", $includeACLs);
  if (! $success) {
    printf("    Error exporting %s", $personaPageName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $personaPageCount++;
  }
}

$ec->setProperty("preSummary", "$personaCount Personas exported\n$personaPageCount Persona Pages exported");
$ec->setProperty("/myJob/personaExported", $personaCount);
$ec->setProperty("/myJob/personaPageExported", $personaPageCount);
exit($errorCount);

$[/myProject/scripts/backup/safeFilename]
$[/myProject/scripts/backup/saveDslFile]

$[/myProject/scripts/perlLibJSON]
