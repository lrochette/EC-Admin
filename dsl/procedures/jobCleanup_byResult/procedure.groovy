import java.io.File

/*
Copyright 2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-18-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'jobCleanup_byResult'

procedure procName,
  description: '''Delete jobs and the associated workspace based on  result: keeping X goods/warning, and Y failed
Report the number of jobs, the disk space and database space that could/was be deleted.''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
  resourceName: 'local',
{
  step 'deleteJobs.byProject',
    description: '''Script to delete all jobs and workspaces associated to a project
It includes CI and workflows jobs.''',
    shell: 'ec-perl'
}
