#############################################################################
#
#  enableSchedules -- Script to enable schedules.
#  Copyright 2015 Electric-Cloud Inc.
#
#############################################################################
$[/myProject/scripts/perlHeaderJSON]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $execute = "$[execute]";		# a boolean to indicate execution or
								#  report-mode only
my $prop="$[listProperty]";		# Prop where to read the list of schedules

#############################################################################
#
#  Global Variables
#
#############################################################################
my $DEBUG=1;
my $list="";					# list of schedules being enabled
my $errList="";					# List of schdules that could not be enabled
my $nbSchedules=0;				# Number of schedules to enable
my $nbSchedulesError=0;			# Number of schedules which failed enablement
my $nbSchedulesEnabled=0;		# Number of schedules which passed enablement

$list = getP($prop);

# Loop over all returned schedules  
foreach my $line (split('\n', $list)) {
  my ($proj,$sched)=split('\t', $line);
  printf("Enabling %s::%s\n", $proj, $sched) if ($DEBUG);
  
  $nbSchedules++;
  if ($execute eq "true") {
    my($ok, $json, $errMsg, $errCode)=InvokeCommander("SuppressLog IgnoreError", 
    	'modifySchedule', $proj, $sched, {scheduleDisabled=>0});
    if (! $ok) {
      printf("\tIssue re-enabling schedule: $errMsg\n");
      $errList .= $line;
      $ec->setProperty("outcome", "warning");
      $nbSchedulesError ++;
    } else {
      $nbSchedulesEnabled ++;
    }
  }
}



$ec->setProperty("/myJob/errorList", $errList);
$ec->setProperty("/myJob/nbSchedules", $nbSchedules);
$ec->setProperty("/myJob/nbSchedulesError", $nbSchedulesError);
$ec->setProperty("/myJob/nbSchedulesEnabled", $nbSchedulesEnabled);

$[/myProject/scripts/perlLibJSON]











