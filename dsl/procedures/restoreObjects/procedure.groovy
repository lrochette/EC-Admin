import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-18-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'restoreObjects'

procedure procName,
  description: 'A procedure to restore the files created by saveAllObjects',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  formalParameter 'directory',
    description: 'the path where the .xml files reside',
    required: '1',
    type: 'entry'

  formalParameter 'recursive',
    description: 'Load files in sub-directories as well',
    defaultValue: 'false',
    required: '0',
    type: 'checkbox'

  formalParameter 'force',
    defaultValue: 'false',
    required: '0',
    type: 'checkbox'

  formalParameter 'preserveId',
    defaultValue: 'false',
    description: 'restore the object with the original owner',
    required: '0',
    type: 'checkbox'

  formalParameter 'resource',
    defaultValue: 'local',
    description: 'The name of the resources where the .xml files are available',
    required: '0',
    type: 'entry'

  step 'restore',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/restore.pl").text,
    resourceName: '$[resource]',
    shell: 'ec-perl'
}
