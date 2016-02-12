#############################################################################
#
#  restartAgentLinux -- Script to possibly restart an agent.
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################

$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

$ec->setProperty("summary", "Restarting the agent service");
system("echo '/etc/init.d/commanderAgent start' | at now + 1 minute");
system("/etc/init.d/commanderAgent stop");

