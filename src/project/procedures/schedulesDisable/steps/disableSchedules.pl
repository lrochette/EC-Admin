#############################################################################
#
#  disableScheduless -- Script to disable schedules.
#  Copyright 2013-2015 Electric-Cloud Inc.
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
my $prop="$[listProperty]";		# Prop where to save the list

#############################################################################
#
#  Global Variables
#
#############################################################################
my $DEBUG=1;
my $MAX=2000;            		# Limiting the number of Objects returned
my $nbObjs;             		# Number of Objects returned
my $list="";					# list of schedules being diabled
my $nbSchedules=0;				# NUmber of schedules disabled (for testing)

my ($ok, $xPath) = InvokeCommander("SuppressLog", "findObjects", "schedule",
                                        {maxIds => $MAX, 
                                         numObjects => $MAX 
                                        });
# Loop over all returned schedules
my @nodeset=$xPath->findnodes('//schedule');
$nbObjs=scalar(@nodeset);
printf("Search Status: %s.\n%s objects returned.\n", $ok?"success":"failure", $nbObjs) if ($DEBUG);
  
foreach my $node (@nodeset) {
  my $sched=$node->{scheduleName};
  my $proj=$node->{projectName};
  printf("Processing %s::%s\n", $proj, $sched) if ($DEBUG);
  
  if (! ($node->{scheduleDisabled})) {
    printf("\tdisabling ${proj}::$sched\n");
    $nbSchedules++;
    if ($execute eq "true") {
    	$ec->modifySchedule($proj, $sched, {scheduleDisabled=>1});
    }
    $list .= "$proj\t$sched\n";
  }
}

if ($prop ne "") {
	$ec->setProperty($prop, $list); 
};
$ec->setProperty("/myJob/nbSchedules", $nbSchedules);

$[/myProject/scripts/perlLibJSON]







