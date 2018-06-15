import java.io.File

def procName= 'debugPostp'

procedure procName,
  description: '''<html>A procedure to automatize my manual postp debugging process:
<ul>
<li>note jobStepId</li>
<li>cd in the workspace to have access to the original log file</li>
<li>run postp with the same option plus --debugLog and --jobStepId</li>
<li>check the debugLog file for information.</li>
<li>Modify your matcher</li>
<li>Rinse and repeat</li>
</ul>
</html>''',
  jobNameTemplate: '$[/myProject/scripts/jobTemplate]',
{
  step 'getJobStepInformation',
    description: '''Extract a few information from the original job step:
- postp command
- logFile to analyze and its workspace location
- resource on which it was executed
''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/getJobStepInformation.pl").text,
    shell: 'ec-perl'

  step 'rerunPostp',
    description: 'Rerun the same command on the same agent that the original',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/rerunPostp.pl").text,
    resourceName: '$[/myJob/assignedResource]',
    shell: 'ec-perl'
}
