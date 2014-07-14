$[/plugins[EC-Admin]/project/scripts/perlHeaderJSON]

#
# Parameters
#
my $proj="$[project_Name]";
my $proc="$[procedure_Name]";
my $param="$[parameter_Name]";
my $DEBUG=("$[debug]" eq "true")?1:0;
my $delete=("$[delete]" eq "true")?1:0;

#
# GlobalVariables
#
my $nbProj=0;			# Number of projects we checked
my $nbProc=0;			# Number of procedures we checked
my $nbStep=0;			# Number of steps we checked
my $nbParam=0;			# Number of parameters that are/can be removed
my $nbSched=0;			# Number of schedules we checked

#
# Loop over Projects
#
my ($success, $res) = InvokeCommander("SuppressLog", "getProjects");

foreach my $node ($res->findnodes("//project")) {
  my $projName=$node->{projectName};
  my $pluginName=$node->{pluginName};

	# skip plugins  
	next if ($pluginName ne "");
	printf("Processing %s\n", $projName) if ($DEBUG);
    $nbProj++;

  #
  # Loop over procedures
  #
	my ($success, $res2) = InvokeCommander("SuppressLog", "getProcedures", $projName);
	foreach my $node ($res2->findnodes("//procedure")) {
		my $procName=$node->{procedureName};
		printf("    procedure: %s\n", $procName) if ($DEBUG);
		$nbProc++;
    #
    # Loop over steps
    #
    my ($success, $res3) = InvokeCommander("SuppressLog", "getSteps", $projName, $procName);
    foreach my $node ($res3->findnodes("//step")) {
      my $stepName=$node->{stepName};
      printf("        %s\n", $stepName) if ($DEBUG);
      $nbStep++;
      if ( ($node->{subprocedure} eq "$proc") &&
            (($node->{subproject} eq $proj) ||  (($node->{subproject} eq "") && ($projName eq $proj)))
           ) {
        #
        # Process param
        #
        processParam($projName, $procName, $stepName, $param, {'projectName' => $projName, 'procedureName' => $procName, 'stepName' => $stepName});

      }
    }  # step loop
  }  # procedure loop

  next;
  
  #
  # Loop over schedules
  #
  my ($success, $res2) = InvokeCommander("SuppressLog", "getSchedules", $projName);
  foreach my $node ($res2->findnodes("//schedule")) {
    my $schedName=$node->{scheduleName};
    printf("    schedule: %s\n", $schedName) if ($DEBUG);
    $nbSched++;

      if ( ($node->{procedure} eq "$proc") &&
            (($node->{project} eq $proj) ||  (($node->{project} eq "") && ($projName eq $proj)))
           ) {
        #
        # Process param
        #
        my ($ok, $res4)=InvokeCommander("SuppressLog IgnoreError", 'getActualParameter', $param, {'projectName' => $projName, 'scheduleName' => $schedName} );
        if ($ok) {
          $nbParam++;
          printf(" Project: %s\Schedule: %s:\nStep: %s\n", $projName, $schedName);
        }
      }

  }  # schedule loop

}  # project loop

printf("\n\nSummary\n");
printf("Projects  : %d\n", $nbProj);
printf("Procedures: %d\n", $nbProc);
printf("Steps     : %d\n", $nbStep);
printf("Schedules : %d\n", $nbSched);
printf("Params    : %d\n", $nbParam);

$ec->setProperty("summary", sprintf("Projects  : %d\nProcedures: %d\nSteps     : %d\nParams    : %d\n", 
					$nbProj, $nbProc, $nbStep, $nbParam));
                    

sub processParam {
  my ($projName, $procName, $stepName, $paramName)=@_;
  
  my ($ok, $res)=InvokeCommander("SuppressLog IgnoreError", 'getActualParameter', $paramName, {'projectName' => $projName, 'procedureName' => $procName, 'stepName' => $stepName} );
  if ($ok) {
    $nbParam++;
    # printf(" Project: %s\nProcedure: %s:\nStep: %s\n", $projName, $procName, $stepName);

    if ($delete) {
      ($ok, $res)=InvokeCommander("SuppressLog", 'deleteActualParameter', $projName, $procName, $stepName, $paramName );
      if ($ok) {
        printf("      **** Deleted ***\n");
      }
    }
  }
}

$[/plugins[EC-Admin]/project/scripts/perlLibJSON]

