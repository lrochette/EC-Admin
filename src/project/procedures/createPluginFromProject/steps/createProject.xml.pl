$[/myProject/scripts/perlHeader]

my $project="$[Project]";
my $wkSpace="";

if ($osIsWindows) {
  $wkSpace=getP("/myWorkspace/agentUncPath");
} else {
  $wkSpace="$[/myWorkspace/agentUnixPath]";
}  
my $file="$wkSpace/$[/myJob/directoryName]/plugin.$[/myJob/jobId]/META-INF/project.xml";

$ec->export($file, {path=> "/projects/" . $project, relocatable => "true"});

$[/myProject/scripts/perlLib]

