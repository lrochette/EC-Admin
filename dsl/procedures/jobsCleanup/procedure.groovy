import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. lrochette

History:
------------------------------------------------------------------------------
06-17-2018  lrochette    Convert to PluginWizard DSL format
03-05-2015               Fixed Issue #18: bad property in subJC_deleteWorkspace
                         Fixed Issue #19: should skip down machine for local workspace
09-20-2013  lrochette    Rewritten using JSON to increase performance
                         Parameter is also now used to skip number of steps computation
09-12-2013  lrochette    Add a parameter to skip the computation of the disk
                         space used; to speed up the job
*/

def procName= 'jobsCleanup'

procedure procName,
  description: '''Delete jobs older than a number of days, along with the associated workspace.
Report the number of jobs, the disk space and database space that could/was be deleted.''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
  resourceName: 'local',
{
  step 'deleteJobs',
    description: 'Script to delete jobs and workspaces',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/deleteJobs.pl").text,
    shell: 'ec-perl'
}
