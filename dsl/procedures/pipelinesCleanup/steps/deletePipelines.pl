#############################################################################
#
#  deletePipelines -- Script to delete pipeline flowRuntimes
#  Copyright 2013-2019 Electric-Cloud Inc.
#
#############################################################################

# Perl Commander Header
$[/myProject/scripts/perlHeaderJSON]

use DateTime;
use File::Path;
use File::stat;
use Fcntl ':mode';

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $pipelineProperty = "$[pipelineProperty]";
my $timeLimit        =  $[olderThan];
my $executeDeletion  = "$[executeDeletion]";
my $completed        = "$[completed]";
my $pattern          = "$[patternMatching]";
my $currentResource  = "$[assignedResourceName]";  # Resource used to run this
my $chunkSize        =  $[chunkSize];           # Limiting the number of Objects returned

#############################################################################
#
#  Global Variables
#
#############################################################################
my $nbFlowRuntimes=0;        # Number of pipelines to delete potentially

my $nbObjs;                  # Number of Objects returned
my $DEBUG=1;

#############################################################################
#
#  Main
#
#############################################################################

printf("%s pipelineRuntimes older than $timeLimit days (%s).\n",
    $executeDeletion eq "true"?"Deleting":"Reporting",
    calculateDate($timeLimit));
printf("  Selecting  \"%s\" pipelineRuntimes.\n\n", $pattern ) if ($pattern  ne "");

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

# create filterList
my @filterList;
# older than
push (@filterList, {"propertyName" => "finish",
                    "operator" => "lessThan",
                    "operand1" => calculateDate($timeLimit)});
# do not have specific pipeline property
push (@filterList, {"propertyName" => $pipelineProperty,
                    "operator" => "isNull"});
# do not try to delete pipelines alreadyy marked for deletion
push (@filterList, {"propertyName" => "deleted",
                    "operator" => "isNull"});

# pipeline pattern does  match
if ($pattern  ne "") {
  push (@filterList, {"propertyName" => "flowRuntimeName",
                      "operator" => "like",
                      "operand1" => $pattern });
}
# check for pipelineLevel
if ($completed  eq "true") {
  push (@filterList, {"propertyName" => "completed",
                      "operator" => "equals",
                      "operand1" => "1"});
}
my ($success, $xPath);
my $loop=1;
do {
    printf ("Loop: %d\n", $loop) if ($DEBUG);
    ($success, $xPath) = InvokeCommander(
      "SuppressLog", "getPipelineRuntimes",
      {
         maxResults => $chunkSize,
         filter => \@filterList,
         sortKey =>  "finish",
         sortOrder => "ascending"
      });
  # Loop over all returned pipelineRuntimes
  my @nodeset=$xPath->findnodes('//flowRuntime');
  $nbObjs=scalar(@nodeset);
  printf("Search Status: %s.\n%s objects returned.\n", $success?"success":"failure", $nbObjs);

  JOB: foreach my $node (@nodeset) {
    printf("\n");
    $nbFlowRuntimes++;

    my $flowRuntimeId   = $node->{flowRuntimeId};
    my $pipelineName    = $node->{pipelineName};
    my $flowRuntimeName = $node->{flowRuntimeName};

    print "FlowRuntime: $flowRuntimeName ($pipelineName)\n";

    # Delete the pipeline
    if ($executeDeletion eq "true") {
       InvokeCommander("SuppressLog", "deleteFlowRuntime", $flowRuntimeId) ;
       print "  Deleting flowRuntime\n\n";
    }
  }

  $loop++;
} while (($executeDeletion eq "true") && ($nbObjs > 0));

printf("\nSUMMARY:\n");
printf("Total number of flowRuntimes:  %d\n", $nbFlowRuntimes);
$ec->setProperty("/myJob/nbFlowRuntimes", $nbFlowRuntimes);
$ec->setProperty("summary", "$nbFlowRuntimes pipelineRuntimes");

exit(0);

#############################################################################
#
#  Calculate the Date based on now and the number of days required by
#  the user before deleting pipelines
#
#############################################################################
sub calculateDate {
    my $nbDays=shift;
    return DateTime->now()->subtract(days => $nbDays)->iso8601() . ".000Z";
}

# Additional function
$[/myProject/scripts/getDirSize]
$[/myProject/scripts/perlLibJSON]
