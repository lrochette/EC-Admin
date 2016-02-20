$[/myProject/performances/scripts/perf.pm]

my %hostsHash; # List of agents already tested
#Let's loop on Resources
my ($success, $xPath) = InvokeCommander("SuppressLog", "getResources");
my $nodeset = $xPath->find('//resource');

foreach my $node ($nodeset->get_nodelist) {
  my $resName=$node->findvalue('resourceName');
  my $resDisabled=$node->findvalue('resourceDisabled');
  my $agentAlive=$node->findvalue('agentState/alive');
  my $hostName=$node->findvalue('hostName');
  printf("%s\n\t Disabled: %s\n\t alive: %s\n", $resName, $resDisabled, $agentAlive) if ($DEBUG);
  #
  # Create a sub-step only if agent is alive and not disabled
  # to avoid to have to wait (and fail) for unavailable resources
  if ( ($resDisabled eq "0") && ($agentAlive eq "1") && !exists($hostsHash{$hostName})) {
    my $hostName=$node->findvalue('hostName');
	$ec->createJobStep({'jobStepName' => $resName,
                        'subprocedure' => "subPM-ping",
                        'actualParameter'=>[{actualParameterName => 'hostname', value => $hostName},
                        					{actualParameterName => 'resource', value => $resName}]
                        }); 
    $hostsHash{$hostName}=1;  # Mark host as tested
  }
}















