#############################################################################
#
#  restartAgent -- Script to possibly restart an agent.
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################

$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

if ($osIsWindows) {
  system("sc stop commanderAgent");
  system("sc start commanderAgent");
} else {
  system("/etc/init.d/commanderAgent restart");
}
