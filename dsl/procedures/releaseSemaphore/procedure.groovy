import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-17-2018  lrochette    Convert to PluginWizard DSL format
10-04-2013  lrochette    Add job counter to help abort a job.'''
*/

def procName= 'releaseSemaphore'

procedure procName,
  description: 'Procedure to release the token',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  formalParameter 'semaphoreProperty',
    description: 'The path to the property used as a semaphore',
    required: '1',
    type: 'entry'

  formalParameter 'serializationResource',
    description: 'This should point to a resouce with a step limit of 1',
    required: '1',
    type: 'entry'

  step 'decrementSemaphore',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/decrementSemaphore.pl").text,
    shell: 'ec-perl'
}
