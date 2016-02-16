$[/myProject/scripts/perlHeader]
use File::Which qw(which);
use File::Copy qw(move);

my $pluginName="$[/myJob/pluginName]";
my $Version="$[/myJob/Version]";

# Using Commander provided Java
$ENV{'JAVA_HOME'} = $ENV{'COMMANDER_HOME'} . "/jre";

my @args=("\"$[SDKpath]/tools/ant/bin/ant\" build");
system(@args) == 0 or die("system @args failed: $?");

$ec->setProperty("/myJob/report-urls/$pluginName-$Version.jar", "file:/$[/myWorkspace/agentUnixPath]/$[/myJob/directoryName]/$pluginName-$Version.jar");












