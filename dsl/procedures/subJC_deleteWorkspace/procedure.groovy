import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. lrochette

History:
------------------------------------------------------------------------------
06-17-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'subJC_deleteWorkspace'

procedure procName,
{
    formalParameter 'computeUsage',
      defaultValue: '0',
      required: '0',
      type: 'checkbox'

  formalParameter 'executeDeletion',
    defaultValue: '0',
    required: '0',
    type: 'checkbox'


  formalParameter 'linDir',
    required: '0',
    type: 'entry'

  formalParameter 'resName',
    description: 'Resource on which to delete the workspace',
    required: '1',
    type: 'entry'

  formalParameter 'winDir',
    defaultValue: '',
    required: '0',
    type: 'entry'

  step 'deleteWorkspaceDirectory',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/deleteWorkspaceDirectory.pl").text,
    errorHandling: 'failProcedure',
    resourceName: '$[resName]',
    shell: 'ec-perl'

  // Do not Display in the property picker
  property 'standardStepPicker', value: false
}
