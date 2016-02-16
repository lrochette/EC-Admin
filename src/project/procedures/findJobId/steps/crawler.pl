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
my $nbSteps=0;

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
  ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", "project",
                                      {maxIds => $MAX,
                                       numObjects => $MAX,
                                       filter => \@filterList });

foreach my $node ($xPath->findnodes('//project')) {
  my $pName=$node->{'projectName'};
  my $pluginName=$node->{'pluginName',};

  # skip plugins
  next if ($pluginName ne "");
  printf("Processing Project: %s\n", $pName) if ($DEBUG);

  my ($suc2, $xPath) = InvokeCommander("SuppressLog", "getProcedures", $pName);
  foreach my $proc ($xPath->findnodes('//procedure')) {
    my $procName=$proc->{'procedureName'};
    printf("  Procedure: %s\n", $procName) if ($DEBUG);

    #
    # Loop over steps
    #
    my ($suc3, $res3) = InvokeCommander("SuppressLog", "getSteps", $pName, $procName);
    foreach my $node ($res3->findnodes("//step")) {
      my $stepName=$node->{stepName};
      printf("    Step: %s\n", $stepName) if ($DEBUG);

      # is this a sub-procedure call
      if ($node->{subprocedure}) {
        #
        # Loop over parameters
        #
        my ($ok4, $res4)=InvokeCommander("SuppressLog IgnoreError", 'getActualParameters',
          {
            'projectName' => $pName,
            'procedureName' => $procName,
            'stepName' => $stepName
          } );
        foreach my $param ($res4->findnodes('//actualParameter')) {
          my $paramName=$param->{actualParameterName};
          my $value=$param->{value};
          if (grep (/jobId/, $value) ) {
            $nbParams++;
            printf("*** jobId in parameter: %s::%s::%s::%s\n",
              $pName, $procName, $stepName, $paramName);
          }
        }
      }
      my $cmd=$node->{command};
      if (grep (/jobId/, $cmd) ) {
        $nbSteps++;
        printf("*** jobId in command: %s::%s::%s\n",
          $pName, $procName, $stepName);
      }
    }
  }
}

printf("\nSummary:\n");
printf("  Number of steps: $nbSteps\n");
printf("  Number of parameters: $nbParams\n");

$ec->setProperty("/myJob/nbSteps", $nbSteps);
$ec->setProperty("/myJob/nbParams", $nbParams);
$ec->setProperty("summary", "Steps: $nbSteps\nParams: $nbParams");

$[/myProject/scripts/perlLibJSON]



