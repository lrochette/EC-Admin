#############################################################################
#
#  deleteJobs -- Script to delete jobs and workspaces
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################

#
# Perl Commander Header
$[/myProject/scripts/perlHeaderJSON]
use File::Path;
use File::stat;
use Fcntl ':mode';
use DateTime;

#
# Perl Commander library
$[/myProject/scripts/perlLibJSON]

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

#############################################################################
#
#  Global Variables
#
#############################################################################
my $version="1.0";
my $totalWksSize=0;          # Size of workspace files
my $totalNbJobs=0;           # Number of jobs to delete potentially
my $totalNbSteps=0;          # Number of steps to evaluate DB size
my $DBStepSize=10240;        # Step is about 10K in DB

my $MAXJOBS=5000;            # Limiting the number of Objects returned
my $nbObjs;                  # Number of Objects returned

#############################################################################
#
#  Main
#
#############################################################################

printf("%s jobs older than $timeLimit days (%s).\n", 
    $executeDeletion eq "true"?"Deleting":"Reporting", 
    calculateDate($timeLimit));
printf("  Skipping over \"%s\" jobs.\n\n", $jobPattern) if ($jobPattern ne "");

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

do {
  my ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", "job",
                                        {maxIds => $MAXJOBS, 
                                         numObjects => $MAXJOBS,
                                         filter => \@filterList ,
                                         sort => [ {propertyName => "finish",
                                                    order => "ascending"} ]});

  # Loop over all returned jobs
  my @nodeset=$xPath->findnodes('//job');
  $nbObjs=scalar(@nodeset);
  printf("Search Status:\t$success. %s objects returned\n", $nbObjs);
  
  foreach my $node (@nodeset) {
        $totalNbJobs++;
        my $wksSize;

        my $jobId   = $node->{'jobId'};
        my $jobName = $node->{'jobName'};

        print "Job: $jobName\n";

        #
        # Find abort status and outcome
        if ($node->{'abortStatus'} eq "FORCE_ABORT") {
          printf("  Outcome:\tAborted\n");
        } else {
        printf("  Outcome:\t%s\n", $node->{'outcome'});
        }
        #
        # Find number of steps for the jobs
        if ($computeUsage eq "true") {
          my ($success, $xPath) = InvokeCommander("SuppressLog", "findJobSteps", 
                      {'jobId' => $jobId});
          my $nbSteps=scalar($xPath->findnodes('//object'));
          $totalNbSteps += $nbSteps;
          printf("  Job steps:\t%d\n", $nbSteps);
        }
        #  Find the workspaces (there may be more than one if some steps
        #  were configured to use a different workspace)
        my ($success, $xPath) = InvokeCommander("SuppressLog", "getJobInfo",
                                                 $jobId);
        foreach my $wsNode ($xPath->findnodes('//job/workspace')) {
            my $workspace;
            if ($osIsWindows) {
                $workspace = $wsNode->{'winUNC'};
                $workspace =~ s'/'\\'g;
            } else {
                $workspace = $wsNode->{'unix'};
            }

            print "  Workspace:\t$workspace\n" if ($workspace ne "");

            if ($computeUsage eq "true") {
              $wksSize = getDirSize($workspace);
              printf ("    Size:\t%s\n", humanSize($wksSize));
              $totalWksSize += $wksSize;
            }
            if ($executeDeletion eq "true") {
               rmtree ([$workspace])  ;
               print "    Deleting Workspace\n";
            }
        }

        # Delete the job

        if ($executeDeletion eq "true") {
            InvokeCommander("SuppressLog", "deleteJob", $jobId) ;
            print "  Deleting Job\n\n";
        } 
  }  # End for loop
} while (($executeDeletion eq "true") && ($nbObjs == $MAXJOBS));

printf("\nSUMMARY:\n");
printf("Total number of jobs:  %d\n", $totalNbJobs);
$ec->setProperty("/myJob/numberOfJobs", $totalNbJobs);

if ($totalNbJobs == $MAXJOBS) {
  printf("There are potentially more jobs to access. Click Run again!\n");
  $ec->setProperty("summary", $totalNbJobs . " jobs deleted. RUN AGAIN!" ) if ($executeDeletion eq "true");
} else {
  $ec->setProperty("summary", $totalNbJobs . " jobs deleted" ) if ($executeDeletion eq "true");
}
if ($computeUsage eq "true") {
  printf("Total File size:       %s\n", humanSize($totalWksSize));
  $ec->setProperty("/myJob/diskSpace", $totalWksSize);
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


#############################################################################
#
#  Calculate the size of the workspace directory
#
#############################################################################
sub getDirSize {
  my $dir  = shift;
  my $size = 0;

  opendir(D,"$dir") || return 0;
  foreach my $dirContent (grep(!/^\.\.?/,readdir(D))) {
     my $st=stat("$dir/$dirContent");
     if (S_ISREG($st->mode)) {
       $size += $st->size;
     } elsif (S_ISDIR($st->mode)) {
       $size += getDirSize("$dir/$dirContent");
     }
  }
  closedir(D);
  return $size;
}

