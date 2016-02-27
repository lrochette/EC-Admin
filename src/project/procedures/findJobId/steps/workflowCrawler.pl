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

      # is this a sub-procedure or sub-workflow call
      if (($node->{subprocedure}) || ($node->{subworkflowDefinition})) {
        #
        # Loop over parameters
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
            printf("*** jobId in parameter: %s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $paramName);
          }
          if (grep (/jobStepId/, $value) ) {
            $nbParams++;
            printf("*** jobStepId in parameter: %s::%s::%s::%s\n",
              $pName, $wkfName, $stateName, $paramName);
          }
        }
      }
    }
  }
}

printf("\nSummary:\n");
printf("  Number of parameters: $nbParams\n");

$ec->setProperty("/myJob/nbStateParams", $nbParams);
$ec->setProperty("summary", "Params: $nbParams");

$[/myProject/scripts/perlLibJSON]


