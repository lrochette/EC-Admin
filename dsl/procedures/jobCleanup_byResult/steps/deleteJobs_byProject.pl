#############################################################################
#
#  deleteJobs_byResult -- Script to delete jobs and workspaces keeping
#                         some good and failed ones.
#  Copyright 2013-2015 Electric-Cloud Inc.
#
#############################################################################

#
# Perl Commander Header
$[/myProject/scripts/perlHeaderJSON]
use File::Path;
use File::stat;
use Fcntl ':mode';
use DateTime;


#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $jobProperty     = "$[jobProperty]";
my $executeDeletion = "$[executeDeletion]";
my $nbGood          =  $[nbGoodJobs];
my $nbFail          =  $[nbFailedJobs];
my $nbWarn          =  $[nbWarningJobs];
my $skipPluginBool  = "$[skipPlugins]";
my $timeLimit       =  $[olderThan];
my $computeUsage    = "$[computeDiskUsage]";

my $currentResource = "$[assignedResourceName]";  # Resource used to run this

#############################################################################
#
#  Global Variables
#
#############################################################################
my $totalNbJobs=0;           # Number of jobs to delete potentially
my $totalNbSteps=0;          # Number of steps to evaluate DB size
my $DBStepSize=10240;        # Step is about 10K in DB
$ec->setProperty("/myJob/totalDiskSpace", 0); #Space on disk

my $procGood=0;				 # Number of good jobs in the procedure kept
my $procFailed=0;		     # Number of failed jobs in the procedure kept
my $procWarning=0;	         # Number of warning jobs in the procedure kept

$DEBUG=0;

#############################################################################
#
#  Main
#
#############################################################################
printf("%s jobs older than $timeLimit days (%s)  based on results.\n", 
    $executeDeletion eq "true"?"Deleting":"Reporting",
    calculateDate($timeLimit));
printf("  Preserving %d GOOD    jobs\n", $nbGood);
printf("  Preserving %d WARNING jobs\n", $nbWarn);
printf("  Preserving %d FAIL    jobs\n\n", $nbFail);

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

#
# Loop over each project 
#
my ($success, $json) = InvokeCommander("SuppressLog", "getProjects");
foreach my $projNode ($json->findnodes("//project")) {
  my $projName  =$projNode->{projectName};
  my $pluginName=$projNode->{pluginName};
  
  # skip plugins if Boolean is set
  next if (($pluginName ne "") && ($skipPluginBool eq "true"));

  printf("Project: %s\n", $projName);
  my $previousProcName="";

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
  # jobs of a specific project
  push (@filterList, {"propertyName" => "projectName",
                      "operator" => "equals",
                      "operand1" => $projName});
  # do not have specific job property
  push (@filterList, {"propertyName" => $jobProperty,
                        "operator" => "isNull"});

  # Getting the list sorted by procedure
  # then by date (or jobId)
  my ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", "job",
                                            {maxIds => 5000,
                                             filter => \@filterList ,
                                             sort => [ {propertyName => "procedureName",
                                                        order => "ascending"} ,
                                                       {propertyName => "jobId",
                                                        order => "descending"} ]});

  # Loop over all returned jobs
  foreach my $node ($xPath->findnodes('//job')) {
    my $wksSize;
    my %wksList={};
    my %processedWks={};

    my $jobId        = $node->{jobId};
    my $jobName      = $node->{jobName};
    my $jobOutcome   = $node->{outcome};
    my $jobProcedure = $node->{procedureName};
    if ($jobProcedure ne $previousProcName) {
      $previousProcName=$jobProcedure;
      $procGood=0;
      $procFailed=0;
      $procWarning=0;
      my $displayName=$jobProcedure;
      # transforn procedure name to standard PROJ:PROC string
      if ($displayName =~ m#/projects/([^/]+)/procedures/([^/]+)#) {
        $displayName="$1:$2";
      }
      print "  Procedure: $displayName\n";    
    }
    print "    Job: $jobName\n";
      
    # Skiping over X GOOD and Y BAD
    if (($procGood < $nbGood) && ($jobOutcome eq "success")) {
      printf ("      Preserving job (GOOD)\n");
      $procGood++;
      next;
    }
    if (($procWarning < $nbWarn) && ($jobOutcome eq "warning")) {
      printf ("      Preserving job (WARNING)\n");
      $procWarning++;
      next;
    }
    if (($procFailed < $nbFail) && ($jobOutcome eq "error")) {
      printf ("      Preserving job (ERROR)\n");
      $procFailed++;
      next;
    }

    $totalNbJobs++;

    #  Find the workspaces (there may be more than one if some steps
    #  were configured to use a different workspace)
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
      next if ($jobStepWks eq "");    # Nothing to do for a step without workspace

    my $jobStepHost=$step->{assignedResourceName};
      next if  ($jobStepHost eq "");  # nothing to do for no resource

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
          $ec->createJobStep({
              subprocedure=>"subJC_deleteWorkspace",
              jobStepName => "Delete $jobStepWks-$jobStepHost-$totalNbSteps",
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
      print "      Deleting Job\n\n";
    } 
  } #job loop
} #project loop

printf("\nSUMMARY:\n");
printf("Total number of jobs:  %d\n", $totalNbJobs);
$ec->setProperty("/myJob/numberOfJobs", $totalNbJobs);

if ($computeUsage eq "true") {
  printf("Total File size:       %s\n", humanSize(getP("/myJob/totalDiskSpace")));
  printf("Total number of steps: %d\n", $totalNbSteps);
  printf("Total Database size:   %s\n", humanSize($totalNbSteps * $DBStepSize));
  $ec->setProperty("/myJob/numbernumberOfSteps", $totalNbSteps);
}

$ec->setProperty("summary", $totalNbJobs . " jobs deleted" ) if ($executeDeletion eq "true");

exit(0);


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

#
# Perl Commander library
$[/myProject/scripts/perlLibJSON]

