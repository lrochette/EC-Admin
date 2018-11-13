import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-20-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'sub-pac_createConfigurationCode'

procedure procName,
  description: '''sub-procedure to create the code, properties on the current
project to transform into a plugin to manage credential configuration''',
{
  formalParameter 'pluginName',
    description: 'The name of the plugin to build',
    required: '1',
    type: 'entry'

  formalParameter 'Project',
    description: 'The project name',
    required: '1'
    type: 'entry'

  step 'create_ui_forms',
    description: 'those 2 forms are required if you want to create configuration',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_ui_forms.pl").text,
    shell: 'ec-perl'

  step 'create_promoteAction',
    description: 'The promoteAction is used to add code automatically to ec_setup.pl',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_promoteAction.pl").text,
    shell: 'ec-perl'

  step 'create_createConfiguration_procedure',
    description: 'create the "createConfiguration" procedure to match the UI form',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_createConfiguration_procedure.pl").text,
    shell: 'ec-perl'

  step 'create_createConfiguration_CreateConfiguration_step',
    description: 'create the "createConfiguration" step in the "createConfiguration" procedure to match the UI form',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_createConfiguration_CreateConfiguration_step.pl").text,
    shell: 'ec-perl'

  step 'create_createConfiguration_createAndAttachCredential',
    description: 'create the step createAndAttachCredential in the "createConfiguration" procedure',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_createConfiguration_createAndAttachCredential.pl").text,
    shell: 'ec-perl'

  step 'attach_parameter_credential',
    description: 'attach the parameter credential to the step "createAndAttachCredential"',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/attach_parameter_credential.pl").text,
    shell: 'ec-perl'

  step 'create_DeleteConfiguration_procedure',
    description: 'create the "DeleteConfiguration" procedure to match the UI form',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_DeleteConfiguration_procedure.pl").text,
    shell: 'ec-perl'

  step 'create_DeleteConfiguration_DeleteConfiguration_step',
    description: 'create the "DeleteConfiguration" step in the "DeleteConfiguration" procedure to match the UI form',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_DeleteConfiguration_DeleteConfiguration_step.pl").text,
    shell: 'ec-perl'

    // Do not Display in the property picker
    property 'standardStepPicker', value: false
}
