import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-19-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'schedulesEnable'
procedure procName,
  description: 'A procedure to re-enable all the schedules you have previously disabled.',
{
  step 'enableSchedules',
    description: 'This step enable all the schedules previously disabled.',
    shell: 'ec-perl'

}
