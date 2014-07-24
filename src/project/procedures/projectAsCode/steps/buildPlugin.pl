$[/myProject/scripts/perlHeader]
use File::Which qw(which);
use File::Copy qw(move);

my $pluginName="$[/myJob/pluginName]";
my $Version="$[/myJob/Version]";

if (my $ant_path=which('ant')) {
  my @args=("ant build");
  system(@args) == 0 or die("system @args failed: $?");
} else {
  printf("ant not found in the path\n");
  $ec->setProperty("summary", "No ant executable in the PATH");
  exit(1);
}

$ec->setProperty("/myJob/report-urls/$pluginName-$Version.jar", "file:/$[/myWorkspace/agentUnixPath]/$[/myJob/directoryName]/$pluginName-$Version.jar");


