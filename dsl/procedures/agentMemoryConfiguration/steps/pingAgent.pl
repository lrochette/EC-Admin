$[/myProject/scripts/perlHeaderJSON]

# Phases:
#   0: agent is still up
#   1: agent is down
#   2: agent is up and pinged
my $phase=0;
my $i=0;
$ec->setProperty("summary", "Waiting for agent to go down");

for ($i=1;$i<10;$i++) {
  printf("Loop %d:\n", $i);
  sleep(30);
  my($ok, $json, $errMsg, $errCode)=InvokeCommander("", 'pingResource', '$[agent]');
  my $state=$json->{responses}->[0]->{resource}->{resourceAgentState};
  $ec->setProperty("summary", "Agent is $state");
  if (($phase == 1) && ($state =~ /alive/)) {
    $phase=2;
    $ec->setProperty("summary", "Done. Agent is $state");
    exit(0);
  }
  else {
    if (($phase == 0) && ($state =~ /down/)) {
      $phase=1;
      $ec->setProperty("summary", "Agent restarting");
    }
  }
  printf("\n\n\n-----------------\n\n");
}
$ec->setProperty("summary", "Agent never came back");
exit(1);
$[/myProject/scripts/perlLibJSON]
