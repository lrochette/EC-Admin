#############################################################################
#
#  deleteJobs_byResult -- Script to delete jobs and workspaces keeping
#                         some good and failed ones.
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################

#
# Perl Commander Header
$[/myProject/scripts/perlHeader]
use File::Path;
use File::stat;
use Fcntl ':mode';
use DateTime;

#
# Perl Commander library
$[/myProject/scripts/perlLib]

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
my $computeDiskUsage= "$[computeDiskUsage]";

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

my $procGood=0;				 # Number of good jobs in the procedure kept
my $procFailed=0;		     # Number of failed jobs in the procedure kept
my $procWarning=0;		     # Number of warning jobs in the procedure kept

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


#
# Loop over each project 
#
my ($success, $pjPath) = InvokeCommander("SuppressLog", "getProjects");
my $projSet = $pjPath->find('//project');
foreach my $pjNode ($projSet->get_nodelist) {
  my $projName  =$pjPath->findvalue('projectName', $pjNode);
  my $pluginName=$pjPath->findvalue('pluginName',  $pjNode);
  
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
  my $nodeset = $xPath->find('//job');
  foreach my $node ($nodeset->get_nodelist) {
    my $wksSize;

    my $jobId     = $xPath->findvalue('jobId',   $node);
    my $jobName   = $xPath->findvalue('jobName', $node);
    my $jobOutcome= $xPath->findvalue('outcome', $node);
    my $jobProcedure=$xPath->findvalue('procedureName', $node);
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

    #
    # Find number of steps for the jobs
    my ($success, $xPath) = InvokeCommander("SuppressLog", "findJobSteps", 
                    {'jobId' => $jobId});
    my $nbSteps=scalar($xPath->findnodes('//object')->get_nodelist);
    $totalNbSteps += $nbSteps;
    printf("      Job steps:\t%d\n", $nbSteps) if ($DEBUG);

    #  Find the workspaces (there may be more than one if some steps
    #  were configured to use a different workspace)
    my ($success, $xPath) = InvokeCommander("SuppressLog", "getJobInfo",
                                               $jobId);
    my $wsNodeset = $xPath->find('//job/workspace');
    foreach my $wsNode ($wsNodeset->get_nodelist) {
      my $workspace;
      if ($osIsWindows) {
        $workspace = $xPath->findvalue('./winUNC', $wsNode);
        $workspace =~ s'/'\\'g;
      } else {
        $workspace = $xPath->findvalue('./unix', $wsNode);
      }

      print "      Workspace:\t$workspace\n" if (($workspace ne "") &&  ($DEBUG));

      if ($computeDiskUsage eq "true") {
        $wksSize = getDirSize($workspace);
        printf ("        Size:\t%s\n", humanSize($wksSize)) if ($DEBUG);
        $totalWksSize += $wksSize;
      }
      if ($executeDeletion eq "true") {
        rmtree ([$workspace])  ;
        print "        Deleting Workspace\n" if ($DEBUG);
      }
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
printf("Total File size:       %s\n", humanSize($totalWksSize))  if ($computeDiskUsage eq "true");
printf("Total number of steps: %d\n", $totalNbSteps);
printf("Total Database size:   %s\n", humanSize($totalNbSteps * $DBStepSize));

$ec->setProperty("/myJob/numberOfJobs", $totalNbJobs);
$ec->setProperty("/myJob/diskSpace", $totalWksSize) if ($computeDiskUsage eq "true");
$ec->setProperty("/myJob/numbernumberOfSteps", $totalNbSteps);

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

