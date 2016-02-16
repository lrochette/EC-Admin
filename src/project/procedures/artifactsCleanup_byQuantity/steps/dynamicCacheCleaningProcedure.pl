#############################################################################
#
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################

use DateTime;

$[/myProject/scripts/perlHeader]
$[/myProject/scripts/perlLib]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $executeDeletion="$[executeDeletion]";
my $days=$[olderThan];

#Let's loop on Resources
my ($success, $xPath) = InvokeCommander("SuppressLog", "getResources");
my $nodeset = $xPath->find('//resource');

foreach my $node ($nodeset->get_nodelist) {
  my $resName=$node->findvalue('resourceName');
  my $hostName=$node->findvalue('hostName');
  my $resDisabled=$node->findvalue('resourceDisabled');
  my $agentAlive=$node->findvalue('agentState/alive');
  printf("%s\n\t Disabled: %s\n\t alive: %s\n", $resName, $resDisabled, $agentAlive);

  #
  # Create a sub-step only if agent is alive and not disabled
  # to avoid to have to wait (and fail) for unavailable resources
  if ( ($resDisabled eq "0") && ($agentAlive eq "1")) {
    my $resName=$node->findvalue('resourceName');
    my $stepName = "clean Artifact Cache Step For ".$resName;
    $ec->createJobStep({'jobStepName'=>$stepName, 
                        'subprocedure' => 'cleanupCacheDirectory', 
                        'actualParameter' => [{'actualParameterName'=>'executeDeletion', 'value'=>$executeDeletion},
                                         {'actualParameterName'=>'olderThan', 'value'=>$days},
                                         {'actualParameterName'=>'resource', 'value'=>$resName}]
                  });
  }
}                      













