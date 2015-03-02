$[/myProject/scripts/perlHeaderJSON]

###################################################################
#
# Parameters
#
###################################################################
my $pluginName="$[Plugin]";
my $project="$[Project]";
my $version="$[Version]";
my $description="$[Description]";
my $comment="$[Comment]";


if ($pluginName eq "") {
  $pluginName=$project;
}

$ec->setProperty("/myJob/shortVersion", $version);

my $pluginBuildNumber=$[/increment /projects/$[Project]/pluginBuildNumber];
my $completeVersion="$version.$pluginBuildNumber";

$ec->setProperty("summary", "Processing plugin $pluginName-$completeVersion");
$ec->setProperty("/myJob/Version", $completeVersion);

# If plugin name is empty default to the projectName
$ec->setProperty("/myJob/pluginName", $pluginName);

# If description is empty, use the project description
if ($description eq "") {
  $description=getP("/projects/$project/description");
}

if ($comment ne "") {
  $description .= "\n$[/timestamp YYYY-MM-dd] $[/myJob/launchedByUser] $[comment]";
}
$ec->setProperty("/myJob/pluginDescription", $description);


$[/myProject/scripts/perlLibJSON]




