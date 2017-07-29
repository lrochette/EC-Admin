############################################################################
#
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

############################################################################
#
# parameters
#
############################################################################
my $pattern="$[projectPattern]";

############################################################################
#
# Global variables
#
############################################################################
$DEBUG=0;
my ($success, $xPath);
my $MAX=5000;
my $nbParams=0;
my $nbStates=0;
my $nbTransConds=0;
my $nbProps=0;

# create filterList
my @filterList;
if ($pattern ne "") {
  push (@filterList, {"propertyName" => "projectName",
                      "operator" => "like",
                      "operand1" => $pattern
                    }
  );
}
push (@filterList, {"propertyName" => "pluginName",
                      "operator" => "isNull"});

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", "project",
                                      {maxIds => $MAX,
                                       numObjects => $MAX,
                                       filter => \@filterList });

foreach my $node ($xPath->findnodes('//project')) {
  my $pName=$node->{'projectName'};
  printf("Processing Project: %s\n", $pName) if ($DEBUG);


  # Process procedures
  #
  my ($suc2, $res2) = InvokeCommander("SuppressLog", "getWorkflowDefinitions", $pName);
  foreach my $proc ($res2->findnodes('//workflowDefinition')) {
    my $wkfName=$proc->{'workflowDefinitionName'};
    printf("  workflow Definition: %s\n", $wkfName) if ($DEBUG);

    #
    # Loop over states
    #
    my ($suc3, $res3) = InvokeCommander("SuppressLog", "getStateDefinitions", $pName, $wkfName);
    foreach my $node ($res3->findnodes("//stateDefinition")) {
      my $stateName=$node->{stateDefinitionName};
      printf("    State: %s\n", $stateName) if ($DEBUG);

      # is this a sub-procedure or sub-workflow call?
      if (($node->{subprocedure}) || ($node->{subworkflowDefinition})) {
        #
        # Loop over state parameters
        #
        my ($ok4, $res4)=InvokeCommander("SuppressLog IgnoreError", 'getActualParameters',
          {
            'projectName' => $pName,
            'workflowDefinitionName' => $wkfName,
            'stateDefinitionName' => $stateName
          } );
        foreach my $param ($res4->findnodes('//actualParameter')) {
          my $paramName=$param->{actualParameterName};
          my $value=$param->{value};
          if (grep (/jobId/, $value) ) {
            $nbParams++;
            printf("*** jobId in state parameter: %s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $paramName);
          }
          if (grep (/jobStepId/, $value) ) {
            $nbParams++;
            printf("*** jobStepId in state parameter: %s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $paramName);
          }
          if (grep (/workflowId/, $value) ) {
            $nbParams++;
            printf("*** workflowId in state parameter: %s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $paramName);
          }
        }     # state parameter loop
      }       # sub-procedure sub-workflow

      #
      # process top level stateDefinition properties
      #
      my ($suc1, $res1) = InvokeCommander("SuppressLog", "getProperties",
        {
          projectName              => $pName,
          workflowDefinitionName   => $wkfName,
          stateDefinitionName      => $stateName,
          recurse => 0,
          expand => 0
        });
      foreach my $prop ($res1->findnodes('//property')) {
        my $propName=$prop->{'propertyName'};
        my $value=$prop->{'value'};
        printf("  Property: %s\n", $propName) if ($DEBUG);

        if (grep (/jobId/, $value) ) {
          $nbProps++;
          printf("*** jobId in state property: %s::%s::%s::%s\n",
                 $pName, $wkfName, $stateName, $propName);
        }
        if (grep (/jobStepId/, $value) ) {
          $nbProps++;
          printf("*** jobStepId in state property: %s::%s::%s::%s\n",
                 $pName, $wkfName, $stateName, $propName);
        }
        if (grep (/workflowId/, $value) ) {
          $nbProps++;
          printf("*** workflowId in state property: %s::%s::%s::%s\n",
                 $pName, $wkfName, $stateName, $propName);
        }
      }

      #
      # loop on transition
      #
      my ($ok5, $res5) = InvokeCommander("SuppressLog", 'getTransitionDefinitions',
          $pName, $wkfName, $stateName);
      foreach my $trans ($res5->findnodes("//transitionDefinition")) {
        my $transName = $trans->{transitionDefinitionName};
        my $condition = $trans->{condition};
        printf("      transition: %s\n", $transName) if ($DEBUG);

        if (grep (/jobId/, $condition) ) {
          $nbTransConds++;
          printf("*** jobId in transition condition: %s::%s::%s::%s\n",
            $pName, $wkfName, $stateName, $transName);
        }
        if (grep (/jobStepId/, $condition) ) {
          $nbTransConds++;
          printf("*** jobStepId in transition parameter: %s::%s::%s::%s\n",
            $pName, $wkfName, $stateName, $transName);
        }
        if (grep (/workflowId/, $condition) ) {
          $nbTransConds++;
          printf("*** workflowId in transition parameter: %s::%s::%s::%s\n",
            $pName, $wkfName, $stateName, $transName);
        }

        #
        # process top level transitionDefinition properties
        #
        my ($suc1, $res1) = InvokeCommander("SuppressLog", "getProperties",
          {
            projectName              => $pName,
            workflowDefinitionName   => $wkfName,
            stateDefinitionName      => $stateName,
            transitionDefinitionName => $transName,
            recurse => 0,
            expand => 0
          });
        foreach my $prop ($res1->findnodes('//property')) {
          my $propName=$prop->{'propertyName'};
          my $value=$prop->{'value'};
          printf("  Property: %s\n", $propName) if ($DEBUG);

          if (grep (/jobId/, $value) ) {
            $nbProps++;
            printf("*** jobId in transition property: %s::%s::%s::%s::%s\n",
                   $pName, $wkfName, $stateName, $transName, $propName);
          }
          if (grep (/jobStepId/, $value) ) {
            $nbProps++;
            printf("*** jobStepId in transition property: %s::%s::%s::%s::%s\n",
                   $pName, $wkfName, $stateName, $transName, $propName);
          }
          if (grep (/workflowId/, $value) ) {
            $nbProps++;
            printf("*** workflowId in transition property: %s::%s::%s::%s::%s\n",
                   $pName, $wkfName, $stateName, $transName, $propName);
          }
        }
        #
        # Loop over transition parameters
        #
        my ($ok4, $res4)=InvokeCommander("SuppressLog IgnoreError", 'getActualParameters',
          {
            'projectName' => $pName,
            'workflowDefinitionName' => $wkfName,
            'stateDefinitionName' => $stateName,
            'transitionDefinitionName' => $transName
          } );

        foreach my $param ($res4->findnodes('//actualParameter')) {
          my $paramName=$param->{actualParameterName};
          my $value=$param->{value};
          if (grep (/jobId/, $value) ) {
            $nbParams++;
            printf("*** jobId in transition parameter: %s::%s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $transName, $paramName);
          }
          if (grep (/jobStepId/, $value) ) {
            $nbParams++;
            printf("*** jobStepId in transition parameter: %s::%s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $transName, $paramName);
          }
          if (grep (/workflowId/, $value) ) {
            $nbParams++;
            printf("*** workflowId in transition parameter: %s::%s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $transName, $paramName);
          }
        }     # transition parameter loop
      }       # transitionDefinition loop
    }         # state loop
  }           # workflowDefinition loop
}             # project loop

printf("\nSummary:\n");
printf("  Number of parameters: $nbParams\n");
printf("  Number of properties: $nbProps\n");
printf("  Number of conditions: $nbTransConds\n");

$ec->setProperty("/myJob/nbStateParams", $nbParams);
$ec->setProperty("/myJob/nbStateProps", $nbProps);
$ec->setProperty("/myJob/nbTransCond", $nbTransConds);
$ec->setProperty("summary", "Params: $nbParams\nProps: $nbProps\nConds: $nbTransConds");

$[/myProject/scripts/perlLibJSON]


