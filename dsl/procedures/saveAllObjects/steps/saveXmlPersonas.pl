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
my $personaCount=0;
my $personaPageCount=0;

# personas were introduced in 8.5
my $version=getVersion();
if (compareVersion($version, "9.0") < 0) {
  $ec->setProperty("Personas were introduced only 9.0");
  exit(0);
}

# Get list of Personas
my ($success, $xPath) = InvokeCommander("SuppressLog", "getPersonas");

# Create the Personas directory
mkpath("$path/Personas");
chmod(0777, "$path/Personas");

foreach my $node ($xPath->findnodes('//persona')) {
  my $personaName=$node->{'personaName'};

  # skip personas that don't fit the pattern
  next if ($personaName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("Saving Persona: %s\n", $personaName);
  my $filePersonaName=safeFilename($personaName);

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/Personas/$filePersonaName".".xml",
  { 'path'=> "/personas[$personaName]",
    'relocatable' => $relocatable,
    'withAcls'    => $includeACLs,
    'withNotifiers'=>$includeNotifiers});
  if (! $success) {
    printf("  Error exporting %s", $personaName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $personaCount++;
  }
}

# Create the Persona Pages directory
mkpath("$path/PersonaPages");
chmod(0777, "$path/PersonaPages");

foreach my $node ($xPath->findnodes('//personaPages')) {
  my $personaPageName=$node->{'personaPageName'};

  # skip personaPages that don't fit the pattern
  next if ($personaPageName !~ /$pattern/$[caseSensitive] ); # / for color mode

  printf("Saving PersonaPage: %s\n", $personaPageName);
  my $filePersonaPageName=safeFilename($personaPageName);

  my ($success, $res, $errMsg, $errCode) =
      InvokeCommander("SuppressLog", "export", "$path/PersonaPages/$filePersonaPageName".".xml",
  { 'path'=> "/personaPages[$personaPageName]",
    'relocatable' => $relocatable,
    'withAcls'    => $includeACLs,
    'withNotifiers'=>$includeNotifiers});
  if (! $success) {
    printf("  Error exporting %s", $personaPageName);
    printf("  %s: %s\n", $errCode, $errMsg);
    $errorCount++;
  } else {
    $personaPageCount++;
  }
}

$ec->setProperty("preSummary", "$personaCount Personas exported\n   $personaPageCount Persona Pages exported");
$ec->setProperty("/myJob/personaExported", $personaCount);
$ec->setProperty("/myJob/personaPageExported", $personaPageCount);
xit($errorCount);

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]
