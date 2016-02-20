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
my $nbJobs=0;

# create filterList
my @filterList;
# only finished jobs
push (@filterList, {"propertyName" => "status",
                    "operator" => "equals",
                    "operand1" => "completed"});

#
# get newest first
my ($ok, $res)= InvokeCommander("SuppressLog", "findObjects", "jobs",
                                 {numObjects => $totalJobs,
                                  filter => \@filterList,
                                  sort => [ {propertyName => "finish",
                                                    order => "descending"} ]
                                 }
                                );
foreach my $job ($res->findnodes('//job')) {
	my $elapsedTime=$job->{elapsedTime};
    $nbJobs++;
   	$longestJob=$elapsedTime if ($elapsedTime > $longestJob);
}

printf("Longest job: %d ms\n", $longestJob);
my $averageJob=$longestJob/$nbJobs;
printf("Average job: %d ms\n", $averageJob);

$ec->setProperty("summary", sprintf("long:%03.1f%% \n%03.1f%% Avg", $longestJob, $averageJob));

#
# Perl Commander library
$[/myProject/scripts/perlLibJSON]














