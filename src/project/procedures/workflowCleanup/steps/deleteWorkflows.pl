#############################################################################
#
#  deleteWorkflows -- Script to delete workflowss
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################

#
# Perl Commander Header
$[/myProject/scripts/perlHeader]
use DateTime;

#
# Perl Commander library
$[/myProject/scripts/perlLib]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $wkfProperty     = "$[wkfProperty]";
my $timeLimit       =  $[olderThan];
my $executeDeletion = "$[executeDeletion]";
my $wkfPattern      = "$[wkfPatternMatching]"; 

#############################################################################
#
#  Global Variables
#
#############################################################################
my $version="1.0";
my $totalNbWkfs=0;          # Number of workflows to delete potentially
my $totalNbStates=0;        # Number of states to evaluate DB size
my $totalNbTrans=0;         # Number of transitions to evaluate DB size
my $DBStateSize=10240;      # State is about 10K in DB
my $DBTransSize=5120;       # Transition is about 5K in DB

#############################################################################
#
#  Main
#
#############################################################################

printf("%s workflows older than $timeLimit days (%s).\n", 
    $executeDeletion eq "true"?"Deleting":"Reporting", 
    calculateDate($timeLimit));
printf("  Skipping over \"%s\" workflows.\n\n", $wkfPattern) if ($wkfPattern ne "");

# create filterList
my @filterList;
# only completed workflows
push (@filterList, {"propertyName" => "completed",
                    "operator" => "equals",
                    "operand1" => "1"});
# older than
if ($timeLimit >0) {
  push (@filterList, {"propertyName" => "finish",
                    "operator" => "lessThan",
                    "operand1" => calculateDate($timeLimit)});
}
                    # do not have specific job property
push (@filterList, {"propertyName" => $wkfProperty,
                    "operator" => "isNull"});
# workflow pattern does not match
if ($wkfPattern ne "") {
  push (@filterList, {"propertyName" => "workflowName",
                      "operator" => "notLike",
                      "operand1" => $wkfPattern});
}              

my ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", "workflow",
                                        {maxIds => 5000,
                                         filter => \@filterList ,
                                         sort => [ {propertyName => "finish",
                                                    order => "ascending"} ]
                                        }
									   );
print "Search Status:\t$success\n";

# Loop over all returned workflows
my $nodeset = $xPath->find('//workflow');
foreach my $node ($nodeset->get_nodelist) {
        $totalNbWkfs++;

        my $wkfName = $xPath->findvalue('workflowName', $node);
		my $projName= $xPath->findvalue('projectName', $node);

        print "Workflow: $wkfName\n";

        #
        # Find number of states for the workflow
		my $nbStates=0;
		my $nbTrans=0;
        my ($success, $stateXML) = InvokeCommander("SuppressLog", "getStates", $projName, $wkfName);
        foreach my $stateNode ($stateXML->find('//state')->get_nodelist) {
		  $nbStates ++;
		  my $stateName=$stateXML->findvalue('stateName', $stateNode);
		  printf("  State name: $stateName\n") if ($DEBUG);
		  #
		  # Find numbers of transitions per state
		  my ($success, $transXML) = InvokeCommander("SuppressLog", "getTransitions", $projName, $wkfName, $stateName);
		  $nbTrans += scalar($transXML->findnodes('//transition')->get_nodelist);
		}
        printf("  Workflow states:\t%d\n", $nbStates);
        printf("  Workflow transitions:\t%d\n", $nbTrans);
		$totalNbStates += $nbStates;
		$totalNbTrans  += $nbTrans;
		
        # Delete the workflow

        if ($executeDeletion eq "true") {
            InvokeCommander("SuppressLog", "deleteWorkflow", $projName, $wkfName) ;
            print "  Deleting Workflow\n\n";
        } 
}

printf("\nSUMMARY:\n");
printf("Total number of workflows:   %d\n", $totalNbWkfs);
printf("Total number of states:      %d\n", $totalNbStates);
printf("Total number of transitions: %d\n", $totalNbTrans);
printf("Total Database size:         %s\n", 
       humanSize($totalNbStates * $DBStateSize + $totalNbTrans * $DBTransSize));

$ec->setProperty("/myJob/numberOfWorkflows", $totalNbWkfs);
$ec->setProperty("/myJob/numbernumberOfStates", $totalNbStates);

$ec->setProperty("summary", $totalNbWkfs . " workflows deleted" ) if ($executeDeletion eq "true");

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





















