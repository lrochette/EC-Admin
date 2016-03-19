#############################################################################
#
#  findSteps -- Script to find steps and figure out where they run
#  Copyright 2014 Electric-Cloud Inc.
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
my $totalTime=0;
my $localTime=0;
my $totalSteps=0;
my $localSteps=0;

my $serverName=lc("$[/server/hostName]");
my $serverIP="$[/server/hostIP]";

# create filterList
my @filterList;
# only finished jobSteps
push (@filterList, {"propertyName" => "status",
                    "operator" => "equals",
                    "operand1" => "completed"});

#
# get newest first
my ($ok, $res)= InvokeCommander("SuppressLog", "findObjects", "jobStep",
                                 {numObjects => $totalJobs,
                                  filter => \@filterList,
                                  sort => [ {propertyName => "finish",
                                                    order => "descending"} ]
                                 }
                                );
foreach my $step ($res->findnodes('//jobStep')) {
    	my $rtime=$step->{runTime};
        my $host=lc($step->{hostName});
        next if ($host eq "");
        $totalSteps++;
        $totalTime+=$rtime;
        if (($host eq "localhost") || ($host eq $serverName) || ($host eq $serverIP)){
          #printf("  Step %s (%d)\n", $step->{stepName}, $rtime)  if ($DEBUG);
          $localTime += $rtime;
          $localSteps ++;
        } else {
          printf("NOT LOCAL: $host  -> %s\n", $step->{stepName}) if ($DEBUG);
        }
}

printf("Job time spent on local: %d ms\n", $localTime);
printf("Total job time: %d ms\n", $totalTime);
my $percTime=$localTime*100/$totalTime;
printf("%.1f%% of job time spent on local\n\n", $percTime);

printf("Number of steps on local: %d\n", $localSteps);
printf("Total number of steps: %d\n", $totalSteps);
my $percSteps=$localSteps*100/$totalSteps;
printf("%.1f%% of steps spent on local\n", $percSteps);

$ec->setProperty("summary", sprintf("%03.1f%% time\n%03.1f%% steps", $percTime, $percSteps));
#
# Perl Commander library
$[/myProject/scripts/perlLibJSON]




















