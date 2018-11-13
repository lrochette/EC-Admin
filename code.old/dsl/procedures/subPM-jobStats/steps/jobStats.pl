#############################################################################
#
#  findSteps -- Script to find steps and figure out where they run
#  Copyright 2015 Electric-Cloud Inc.
#
#############################################################################

$[/myProject/scripts/perlHeaderJSON]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $totalJobs= $[number];
$DEBUG=$[debugMode];

#############################################################################
#
#  Global Variables
#
#############################################################################
my $longestJob=0;
my $total=0;
my $nbJobs=0;

# create filterList
my @filterList;
# only finished jobs
push (@filterList, {"propertyName" => "status",
                    "operator" => "equals",
                    "operand1" => "completed"});

#
# get newest first
my ($ok, $res)= InvokeCommander("SuppressLog", "findObjects", "job",
                                 {numObjects => $totalJobs,
                                  filter => \@filterList,
                                  sort => [ {
                                    propertyName => "finish",
                                    order => "descending"} ]
                                 }
                                );
foreach my $job ($res->findnodes('//job')) {
	my $elapsedTime=$job->{elapsedTime};
  $nbJobs++;
 	$longestJob=$elapsedTime if ($elapsedTime > $longestJob);
  $total=+ $elapsedTime;
}

printf("Longest job: %d ms\n", $longestJob);
my $averageJob=$total/$nbJobs;
printf("Average job: %.1f ms\n", $averageJob);

$ec->setProperty("summary", sprintf("long:%d \n%.1f Avg", $longestJob, $averageJob));

#
# Perl Commander library
$[/myProject/scripts/perlLibJSON]
