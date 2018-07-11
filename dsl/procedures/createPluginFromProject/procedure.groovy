import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
2018-06-19  lrochette   Convert to PluginWizard DSL format
2015-07-11  lrochette   Added --withNotifiers option when exporting the project
2015-02-27  lrochette   Added a moveJobs option to move jobs from old plugin version to the new one
2014-06-18  lrochette   Added a hook to allow actions to be taken when the plugin changes state
2014-05-08  lrochette   Added feature to save plugin as an artifact version
2014-04-30  lrochette   Added step to fix self reference to project
2014-04-29  lrochette   Fixed ec_visbility issue
2014-04-03  lrochette   Fixed problem with ec_setup and procedure names with dot (".")
2014-03-12  lrochette   fixed Email address URL issue
2014-03-11  lrochette   Fixed jar error not reported
                                      Fixed Windows path issue for
                                      Use zip when jar is not available to package plugin
2014-01-31  lrochette   Fixed descriptionForPlugin bug
2014-01-26  lrochette   Fixed ec_visbility  (pickListOnly)
2014-02-04  lrochette   Fixed problem with ec_setup and procedure names with dot (".")
2014-04-02  lrochette   Fixed problem with ec_setup and procedure names with dot (".")
2014-04-29  lrochette   Fixed ec_visbility
2014-04-30  lrochette   Added a step to fix self reference to the project'''

*/

def procName= 'createPluginFromProject'

procedure procName,
  description: '''Create a plugin from a simple project.
OBSOLETE: being replaced by projectAsCode. Keeping it in EC-Admin for current
users but it will not be updated anymore''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'Initialization',
    description: 'Set up some job properties',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/Initialization.pl").text,
    shell: 'ec-perl'

  step 'createFileStructure',
    description: '''Create the file structure required for a plugin
/
	/ META-INF
		/ plugin.xml
		/ project.xml
	/ pages
		/ help.xml
''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/createFileStructure.pl").text,
    shell: 'ec-perl'

  step 'fixSelfReferences',
    description: '''Replace self references in states, schedules and steps to
the current project by an empty String''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/fixSelfReferences.pl").text,
    condition: '$[fixSelfReferences]',
    shell: 'ec-perl'

  step 'createPlugin.xml',
    description: 'create the META-INF/plugin.xml',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/createPlugin_xml.pl").text,
    shell: 'ec-perl'

  step 'setProjectProperty-ec_visbility',
    description: 'set the right properties to be able to see the project in the picketList',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/setProjectProperty-ec_visbility.pl").text,
    shell: 'ec-perl'

  step 'setProjectProperties-ec_setup',
    description: '''set the right properties to be able to see the project in the picketList.
Procedure is added only if property pluginExpose is set''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/setProjectProperties-ec_setup.pl").text,
    shell: 'ec-perl'

  step 'createProject.xml',
    description: 'Create the META-INF/project.xml',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/createProject_xml.pl").text,
    errorHandling: 'abortJob',
    shell: 'ec-perl'

  step 'restore-ec_visibility',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/restore-ec_visibility.pl").text,
    shell: 'ec-perl'

  step 'createHelp.xml',
    description: 'if the property "help" exist for the project, use it to create the pages/help.xml',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/createHelp_xml.pl").text,
    shell: 'ec-perl'

  step 'packagePlugin',
    description: 'Create the jar file for the plugin',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/packagePlugin.pl").text,
    errorHandling: 'abortJob',
    shell: 'ec-perl'

  step 'savePluginAsArtifactVersion',
    description: 'Let\'s save the plugin in the Artifact Repository',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/savePluginAsArtifactVersion.pl").text,
    condition: '$[createArtifact]',
    shell: 'ec-perl'

  step 'installPlugin',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/installPlugin.pl").text,
    condition: '''$[/javascript "$[installPlugin]" == "true" ]''',
    shell: 'ec-perl'

  step 'promotePlugin',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/promotePlugin.pl").text,
    condition: '$[/javascript "$[promotePlugin]" == "true" ]',
    shell: 'ec-perl'
}
