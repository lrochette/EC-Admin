import java.io.File

/*
Copyright 2016-2019 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
03-13-2019  lrochette    initial version based on jobsCleanup
*/

def procName= 'pipelinesCleanup'

procedure procName,
  description: '''Delete pipelines older than a number of days.
Report the number of pipelines that could/were be deleted.''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
  resourceName: 'local',
{
  step 'deletePipelines',
    description: 'Script to delete pipelines and workspaces',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/deletePipelines.pl").text,
    shell: 'ec-perl'
}
