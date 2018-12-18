#############################################################################
#
#  deleteJobs -- Script to delete jobs and workspaces
#  Copyright 2013-2015 Electric-Cloud Inc.
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
my $jobProperty     = "$[jobProperty]";
my $timeLimit       =  $[olderThan];
my $executeDeletion = "$[executeDeletion]";
my $jobLevel        = "$[jobLevel]";
my $jobPattern      = "$[jobPatternMatching]";
my $computeUsage    = "$[computeUsage]";
my $currentResource = "$[assignedResourceName]";  # Resource used to run this
my $maxJobs         = $[maxObjects];              # Limiting the number of Objects returned

#############################################################################
#
#  Global Variables
#
#############################################################################
my $version="1.0";
my $totalNbJobs=0;           # Number of jobs to delete potentially
my $totalNbSteps=0;          # Number of steps to evaluate DB size
my $DBStepSize=10240;        # Step is about 10K in DB
$ec->setProperty("/myJob/totalDiskSpace", 0); #Space on disk

my $nbObjs;                  # Number of Objects returned

my $DEBUG=0;

#############################################################################
#
#  Main
#
#############################################################################

printf("%s $maxJobs jobs older than $timeLimit days (%s).\n",
    $executeDeletion eq "true"?"Deleting":"Reporting",
    calculateDate($timeLimit));
printf("  Skipping over \"%s\" jobs.\n\n", $jobPattern) if ($jobPattern ne "");

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

# create filterList
my @filterList;
# only finished jobs
push (@filterList, {"propertyName" => "status",
                    "operator" => "equals",
                    "operand1" => "completed"});
# older than
push (@filterList, {"propertyName" => "finish",
                    "operator" => "lessThan",
                    "operand1" => calculateDate($timeLimit)});
# do not have specific job property
push (@filterList, {"propertyName" => $jobProperty,
                    "operator" => "isNull"});
# job pattern does not match
if ($jobPattern ne "") {
  push (@filterList, {"propertyName" => "jobName",
                      "operator" => "notLike",
                      "operand1" => $jobPattern});
}
# check for jobLevel
if ($jobLevel eq "Aborted") {
  push (@filterList, {"propertyName" => "abortStatus",
                      "operator" => "equals",
                      "operand1" => "FORCE_ABORT"});
} elsif ($jobLevel eq "Error") {
  push (@filterList, {"propertyName" => "outcome",
                       "operator" => "equals",
                       "operand1" => "error"});
}

my ($success, $xPath);
do {
    ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", "job",
                                        {maxIds => $maxJobs,
                                         numObjects => $maxJobs,
                                         filter => \@filterList,
                                         sort => [ {propertyName => "finish",
                                                    order => "ascending"} ]});
  # Loop over all returned jobs
  my @nodeset=$xPath->findnodes('//job');
  $nbObjs=scalar(@nodeset);
  printf("Search Status: %s.\n%s objects returned.\n", $success?"success":"failure", $nbObjs);

  JOB: foreach my $node (@nodeset) {
    printf("\n");
    $totalNbJobs++;
    my %wksList={};
    my %processedWks={};

    my $jobId   = $node->{jobId};
    my $jobName = $node->{jobName};

    print "Job: $jobName ($jobId)\n";

    #
    # Find abort status and outcome
    if ($node->{'abortStatus'} eq "FORCE_ABORT") {
      printf("  Outcome:\tAborted\n");
    } else {
      printf("  Outcome:\t%s\n", $node->{outcome});
    }
    #
    #  Find the workspaces (there may be more than one if some steps
    #  were configured to use a different workspace)
    #printf("  Processing job workspaces:\n");
    my ($success, $xPath) = InvokeCommander("SuppressLog", "getJobInfo", $jobId);
    WKS: foreach my $wsNode ($xPath->findnodes('//job/workspace')) {
        my $wksName=$wsNode->{'workspaceName'};
        $wksList{$wksName}{defined}=1;
        if (! defined($wsNode->{'workspaceId'})) {
        	printf("WARNING: workspace \'$wksName\' has been deleted. Cannot access directories!\n");
            $ec->setProperty("outcome", "warning");
            $wksList{$wksName}{defined}=0;
            next;
        }
        if ($wsNode->{'local'} == 1) {
          $wksList{$wksName}{'local'} = 1;
          $wksList{$wksName}{'win'} = $wsNode->{'winDrive'};
        } else {
          $wksList{$wksName}{'local'} = 0;
          $wksList{$wksName}{'win'} = $wsNode->{'winUNC'};
        }
        $wksList{$wksName}{'lin'} = $wsNode->{'unix'};
        $wksList{$wksName}{'win'} =~ s'/'\\'g;
        printf("  Workspace: $wksName (%s)\n", $wksList{$wksName}{'local'}?"local":"shared");
        #printf("      Windows: %s\n", $wksList{$wksName}{'win'});
        #printf("      Linux:   %s\n", $wksList{$wksName}{'lin'});
    }

    my ($success, $jSteps) = InvokeCommander("SuppressLog", "findJobSteps",
                  {'jobId' => $jobId});
    STEP: foreach my $step ($jSteps->findnodes('//object/jobStep')) {
      $totalNbSteps ++;
      my $jobStepId=$step->{jobStepId};

	  my $jobStepWks=$step->{workspaceName};
      next if ($jobStepWks eq "");		# Nothing to do for a step without workspace

	  my $jobStepHost=$step->{assignedResourceName};
      next if  ($jobStepHost eq "");	# nothing to do for no resource

	  # skip if we have already processed this workspace on this machine
      next if ($processedWks{$jobStepWks}{$jobStepHost});
	  # skip if the workspace does not exist anymore
      next if ($wksList{$jobStepWks}{defined} == 0);

	  printf("  jobStep: %s\t on workspace: %s\n", $jobStepId, $jobStepWks);

      # Delete Workspace
      if ( ($jobStepHost ne $currentResource) &&
           ($wksList{$jobStepWks}{'local'} == 1)) {
        printf("    Deleting workspace $jobStepWks remotely on $jobStepHost\n");
        if ((getP("/resources/$jobStepHost/agentState/state") eq "alive") &&
            (getP("/resources/$jobStepHost/resourceDisabled") eq "false")) {
          printf("    winDir: '%s'\n", $wksList{$jobStepWks}{win}) if ($DEBUG);
          $wksList{$jobStepWks}{win} = tr/\\/\//;

          $ec->createJobStep({
              subprocedure=>"subJC_deleteWorkspace",
              jobStepName => "Delete $jobStepWks-$jobStepHost-$totalNbSteps",
              timeLimit => "5",
              timeLimitUnits => "minutes",
              actualParameter => [
                {actualParameterName => "computeUsage",    value => $computeUsage},
                {actualParameterName => "executeDeletion", value => $executeDeletion},
                {actualParameterName => "resName",         value => $jobStepHost},
                {actualParameterName => "winDir",          value => $wksList{$jobStepWks}{win}},
                {actualParameterName => "linDir",          value => $wksList{$jobStepWks}{lin}},
              ]});
        } else {
          printf("    Skipping unavailable $jobStepHost\n");
        }
      } else {
          my $wksDir="";
          if ($osIsWindows) {
            $wksDir =  $wksList{$jobStepWks}{win};
          } else {
              $wksDir = $wksList{$jobStepWks}{lin};
          }
          $[/myProject/scripts/deleteWorkspace]
        }
        # mark the workspace for this resource so we don't process it again
        $processedWks{$jobStepWks}{$jobStepHost}=1;
      }
      # Delete the job
      if ($executeDeletion eq "true") {
         InvokeCommander("SuppressLog", "deleteJob", $jobId) ;
         print "  Deleting Job\n\n";
      }
  }  # End foreach $node loop
} while (($executeDeletion eq "true") && ($nbObjs > 0));

printf("\nSUMMARY:\n");
printf("Total number of jobs:  %d\n", $totalNbJobs);
$ec->setProperty("/myJob/numberOfJobs", $totalNbJobs);

if ($totalNbJobs == $maxJobs) {
  printf("There are potentially more jobs to access. Click Run again!\n");
  $ec->setProperty("summary", $totalNbJobs . " jobs deleted. RUN AGAIN!" ) if ($executeDeletion eq "true");
} else {
  $ec->setProperty("summary", $totalNbJobs . " jobs deleted" ) if ($executeDeletion eq "true");
}
if ($computeUsage eq "true") {
  printf("Total File size:       %s\n", humanSize(getP("/myJob/totalDiskSpace")));
  printf("Total number of steps: %d\n", $totalNbSteps);
  printf("Total Database size:   %s\n", humanSize($totalNbSteps * $DBStepSize));
  $ec->setProperty("/myJob/numbernumberOfSteps", $totalNbSteps);
}

exit(0);


#############################################################################
#
#  Calculate the Date based on now and the number of days required by
#  the user before deleting jobs
#
#############################################################################
sub calculateDate {
    my $nbDays=shift;
    return DateTime->now()->subtract(days => $nbDays)->iso8601() . ".000Z";
}

# Additional function
$[/myProject/scripts/getDirSize]

# Perl Commander library
$[/myProject/scripts/perlLibJSON]
