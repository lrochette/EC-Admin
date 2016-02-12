############################################################################
#
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=0;

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProjects");

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
            printf("****        jobId in Parameter: %s::%s::%s::%s\n",
              $pName, $procName, $stepName, $paramName);
          }
        }
      }
      my $cmd=$node->{command};
      if (grep (/jobId/, $cmd) ) {
        printf("****        jobId in command: %s::%s::%s\n",
          $pName, $procName, $stepName);
      }
    }
  }
}

$[/myProject/scripts/perlLibJSON]

