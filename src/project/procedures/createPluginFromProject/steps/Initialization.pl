$[/myProject/scripts/perlHeaderJSON]

###################################################################
#
# Parameters
#
###################################################################
my $pluginName="$[Plugin]";
my $project="$[Project]";
my $version="$[Version]";

if ($pluginName eq "") {
  $pluginName=$project;
}
my $pluginBuildNumber=$[/increment /projects/$[Project]/pluginBuildNumber];
my $completeVersion="$version.$pluginBuildNumber";

$ec->setProperty("summary", "Processing plugin $project-$completeVersion");
$ec->setProperty("/myJob/Version", $completeVersion);
