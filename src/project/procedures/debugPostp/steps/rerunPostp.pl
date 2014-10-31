$[/projects/EC-Admin/scripts/perlHeaderJSON]


#
# Parameters
#
my $stepId="$[myJobStepId]";
my $DEBUG="$[debug]";

#
# Global variables
#
my $cmd="$[/myJob/postpCommand]";
my $logFile='$[/myJob/pathToLog]';

printf("Running postp again\n-------------------\n\n");
$cmd .= " --debugLog thisIsMyDebugFile.log --jobStepId $stepId \"$logFile\"";

printf("command: %s\n\n", $cmd);
system("$cmd");

printf("\n\nResult\n-------\n\n");
open(FD, "<thisIsMyDebugFile.log");
while (<FD>) {
  print $_;
}
close(FD);
