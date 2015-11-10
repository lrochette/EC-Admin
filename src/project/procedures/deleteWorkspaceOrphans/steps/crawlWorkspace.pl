#############################################################################
#
#  crawlWorkspace-- Script to find orphan job directories in a workspace
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################

use File::Path;
use File::stat;
use Fcntl ':mode';
use DateTime;
use Time::localtime;

$[/myProject/scripts/perlHeader]


#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $workspace       = "$[/myParent/workspace]";
my $executeDeletion = "$[/myParent/executeDeletion]";
my $nbDays          =  $[/myParent/olderThan];
my $verboseMode     = "$[/myParent/verboseMode]";
#############################################################################
#
#  Global Variables
#
#############################################################################
my $osIsWindows = $^O =~ /MSWin/;
my $totalWksSize=0;          # Size of workspace files
my $totalNbJobs=0;           # Number of orphans job directories
my $wksDir;
my $timeLimit = time() - $nbDays*24*3600;

#############################################################################
#
#  Main
#
#############################################################################

printf ("%s'%s' workspace for orphan job directories older than %d days (%s)!\n",
        $executeDeletion eq "true"?"Deleting":"Crawling", $workspace, $nbDays,
         ctime($timeLimit));

# Check the workspace
my ($success, $xPath, $errorMsg) = InvokeCommander("SuppressLog", "getWorkspace", $workspace);
if (! $success) {
  printf("Cannot access workspace %s!\n%s\n", $workspace, $errorMsg);
  exit 1;
}

if ($osIsWindows) {
  $wksDir=$xPath->findvalue('//agentUncPath');
  $wksDir=~ s#/#\\#g;
} else {
  $wksDir=$xPath->findvalue('//agentUnixPath');
}
printf ("Workspace directory: %s\n\n", $wksDir);
opendir(D, $wksDir) || die "Cannot access workspace directory $wksDir!\n";
foreach my $dir (grep(!/^\.\.?/, readdir(D))) {
  my $fullPath=$wksDir . "/" . $dir;
  my $fStat=stat($fullPath);
  if (! (S_ISDIR($fStat->mode))) {              # skip non directories
    printf ("%s: not a directory. Skipping!\n", $dir) if ($verboseMode eq "true");
    next;
  }
  if ($dir !~ /[-_\(]\d+/ ) {
    printf("%s: does not match a job name pattern. Skipping!\n", $dir);
    next;
  }
  my $fileTime = $fStat->mtime;         #Modification time

  if ( $fileTime > $timeLimit) {    # Check only older directories
    printf("%s: too recent (%s). Skipping!\n", $dir, ctime($fileTime)) if ($verboseMode eq "true");
    next;
  }
  ($success, $xPath, $errorMsg)=InvokeCommander("SuppressLog", "findObjects", "job", 
                                     {filter => [{"propertyName" => "directoryName", "operator" => "like",
                                                  "operand1" => $dir}]
                                     });
  if (scalar($xPath->find('//object')->get_nodelist) == 0) {
    printf("%s: Orphan\n", $dir);
    my $wksSize = getDirSize("$fullPath");
    printf ("  Size: %s\n", humanSize($wksSize));
    $totalWksSize += $wksSize;
    $totalNbJobs++;
    if ($executeDeletion eq "true") {
       printf("  Deleting\n");
       rmtree ([$fullPath]);                
    }       
  }                           
} # foreach $dir

printf("SUMMARY\n");
printf("Total number of jobs:  %d\n", $totalNbJobs);
printf("Total File size:       %s\n", humanSize($totalWksSize));

exit 0;


#############################################################################
#
#  Calculate the size of a directory
#
#############################################################################
sub getDirSize {
  my $dir  = shift;
  my $size = 0;

  opendir(D,"$dir") || return 0;
  foreach my $dirContent (grep(!/^\.\.?/,readdir(D))) {
     my $st=stat("$dir/$dirContent");
     next if (!$st);	# skip incorrect links
     if (S_ISREG($st->mode)) {
       $size += $st->size;
     } elsif (S_ISDIR($st->mode)) {
       $size += getDirSize("$dir/$dirContent");
     }
}
  closedir(D);
  return $size;
}



$[/myProject/scripts/perlLib]

