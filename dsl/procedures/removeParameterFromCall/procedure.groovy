import java.io.File

/*
Copyright 2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-18-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'removeParameterFromCall'

procedure procName,
  description: '''This procedure parse all the projects, procedures and steps
to remove a parameter from the call. To be used after it has been removed from
a procedure.''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'searchAndRemove',
    description: 'Process all non plugins projects, all procedures and steps, all schedules',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/searchAndRemove.pl").text,
    condition: '0 && Not Ready',
    shell: 'ec-perl'
}
