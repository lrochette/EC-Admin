import java.io.File

def procName= 'workflowCleanup'
procedure procName,
  description: '''Delete workflows older than a number of days.
Report the number of workflows.''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
  resourceName: 'local',
{
  step 'deleteWorkflows',
    description: 'Script to delete workflows',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/deleteWorkflows.pl").text,
    shell: 'ec-perl'
}
