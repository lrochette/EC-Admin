import java.io.File

/*
Copyright 2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-19-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'schedulesDisable'

procedure procName,
  description: 'A procedure to disable all the schedules.',
{
  step 'disableSchedules',
    description: 'This step disable all the schedules',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/disableSchedules.pl").text,
    shell: 'ec-perl'
}
