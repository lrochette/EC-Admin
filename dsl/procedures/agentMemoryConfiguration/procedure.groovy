import java.io.File

def procName = 'agentMemoryConfiguration'
procedure procName,
  description: '''A procedure to modify the java memory setting of an agent.
# Specify java heap size in percentage OR mb.

# Initial Java Heap Size (in %)
#wrapper.java.initmemory.percent=15

# Initial Java Heap Size (in mb)
wrapper.java.initmemory=256

# Maximum Java Heap Size (in %)
#wrapper.java.maxmemory.percent=15

# Maximum Java Heap Size (in mb)
wrapper.java.maxmemory=512
''',
{
  step 'modifyWrapper',
    description: 'Modify the wrapper.conf',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/modifyWrapper.pl").text,
    resourceName: '$[agent]',
    exclusiveMode: 'job',
    shell: 'ec-perl'

  step 'restartAgentLinux',
    description: '''restart the agent.
The agent stops but does not restart''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/restartAgentLinux.pl").text,
    condition: '$[/javascript ("$[restartAgent]" == "true") && ("$[/myJob/platform]" == "linux") ]',
    resourceName: '$[agent]',
    timeLimit: '5',
    parallel: '1',
    errorHanlding: "ignore",
    timeLimitUnits: 'minutes',

    shell: 'ec-perl'

  step 'restartAgentWindows',
    description: '''restart the agent.
The agent stops but does not restart''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/restartAgentWindows.ps1").text,
    condition: '$[/javascript ("$[restartAgent]" == "true") && ("$[/myJob/platform]" == "windows") ]',
    resourceName: '$[agent]',
    timeLimit: '5',
    timeLimitUnits: 'minutes',
    parallel: '1',
    errorHanlding: "ignore",
    shell: 'powershell  "& \'{0}.ps1\'"'
/*
  step 'waitForAgentToGoDown',
    description: 'This gives time to the agent to go down',
    command: 'sleep(30)',
    paralell: '1',
    shell: 'ec-perl'
*/
  step 'pingAgent',
    description: 'Ping the agent after the reboot',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/pingAgent.pl").text,
    parallel: '1',
    resourceName: '$[pingAgent]',
    shell: 'ec-perl'
/*
  step 'waitForAgentToComeBack',
    description: 'The step will be blocked until the agent is available again',
    command: 'echo "Hello world" ',
    condition: '$[agent]',
    resourceName: '$[agent]'
*/
}
