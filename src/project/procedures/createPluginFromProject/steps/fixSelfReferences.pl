#############################################################################
#
# Copyright 2014 Electric-Cloud Inc.
#
#############################################################################

$[/myProject/scripts/perlHeaderJSON]

#############################################################################
#
# Parameters
#
#############################################################################
my $prj="$[Project]";

my $DEBUG=1;

#
# Schedules Loop
# 
my $res=$ec->getSchedules($prj);

foreach my $node ($res->findnodes("//schedule")) {
    my $sched=$node->{'scheduleName'};
	printf("Processing Schedule: %s\n", $sched);

	if ($node->{'project'} eq "$prj") {
    	printf("        *** Changing schedule project back to empty\n");
    	$ec->setProperty('subproject', "", {projectName=>$prj,  scheduleName=>$sched});
  	}
}
printf("\n\n\n");

#
# Workflow/State Definition Loop
# 
$res=$ec->getWorkflowDefinitions($prj);

foreach my $node ($res->findnodes("//workflowDefinition")) {
	my $wkf=$node->{'workflowDefinitionName'};
	printf("Processing Workflow: %s\n", $wkf);

	my $json=$ec->getStateDefinitions($prj, $wkf);
    
	foreach my $state ($json->findnodes("//stateDefinition")) {
    	my $stateName=$state->{'stateDefinitionName'};
  		printf("    Process State %s\n", $stateName);
        if ($state->{'subproject'} eq "$prj") {
    		printf("        *** Changing state subproject back to empty\n");
    		$ec->setProperty('subproject', "", {projectName=>$prj, workflowDefinitionName=>$wkf, stateDefinitionName=>$stateName});
  		}
	}
}
printf("\n\n\n");

#
# Procedure/Step Loop
# 
$res=$ec->getProcedures($prj);

foreach my $node ($res->findnodes("//procedure")) {
	my $proc=$node->{'procedureName'};
	printf("Processing Procedure: %s\n", $proc);

	my $json=$ec->getSteps($prj, $proc);
    
	foreach my $step ($json->findnodes("//step")) {
    	my $stepName=$step->{'stepName'};
  		printf("    Process Step %s\n", $stepName);
        if ($step->{'subproject'} eq "$prj") {
    		printf("        *** Changing step subproject back to empty\n");
    		$ec->setProperty('subproject', "", {projectName=>$prj, procedureName=>$proc, stepName=>$stepName});
  		}
	}
}









