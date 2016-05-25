$[/myProject/scripts/perlHeader]
use File::Which qw(which);
use File::Copy qw(move);

my $pluginName="$[/myJob/pluginName]";
my $Version="$[/myJob/Version]";
my $gradle="./gradlew";
$gradle= "gradlew.bat" if ($osIsWindows);

system("gradle wrapper");
system($gradle) == 0 or die("system $gradle failed: $?");

$ec->setProperty("/myJob/report-urls/$pluginName-$Version.jar", "file:/$[/myWorkspace/agentUnixPath]/$[/myJob/directoryName]/$pluginName-$Version.jar");

