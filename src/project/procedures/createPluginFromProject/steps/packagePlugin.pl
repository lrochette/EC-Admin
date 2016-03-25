$[/myProject/scripts/perlHeader]
use File::Which qw(which);
use File::Copy qw(move);

my $pluginName="$[Plugin]";
my $Version="$[/myJob/Version]";
if ($pluginName eq "") {
  $pluginName="$[Project]";
}

chdir("plugin.$[/myJob/jobId]");

if (my $jar_path=which('jar')) {
  my @args=("jar cvf0 ../$pluginName-$Version.jar *");
  system(@args) == 0 or die("system @args failed: $?");
} else {
  printf("jar not found in the path\n");
  #
  # Let's try with zip
  if (my $zip_path=which('zip')) {
  	printf("Let's try with zip instead\n");
    my @args=("zip -r  ../$pluginName-$Version.zip *");
    system(@args) == 0 or die("system @args failed: $?");
    # let's rename the file
    move("../$pluginName-$[Version].zip", "../$pluginName-$Version.jar");
  } else {
    printf("zip not found in the path\n");
    printf("I need something to package the plugin\n");
    $ec->setProperty("summary", "No jar or zip executable in the PATH");
    exit(1);
  }
}

$ec->setProperty("/myJob/report-urls/$pluginName-$Version.jar", "file:/$[/myWorkspace/agentUnixPath]/$[/myJob/directoryName]/$pluginName-$Version.jar");





















