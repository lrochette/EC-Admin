import java.io.File

/*
Copyright 2014-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
2018-06-17  lrochette   Convert to PluginWizard DSL format
2015-05-29  lrochette   Fixed Issue #32: added code to delete configuration.
2015-04-02  vijaybandari  Use the plugin directory setting instead of the dataDirectory
2015-02-27  lrochette   Added a moveJobs option to move jobs from old plugin version to the new one
2014-12-18  lrochette   JSON lib was missing in Initialization
2014-12-10  kjdowney    Remove ec_visibility Prop
2014-08-27  lrochette   Parse "scripts" PS recursively
2014-08-25  lrochette   Extracting "scripts" PS generally containing code
2014-07-30  lrochette   Fixed "directory" parameter help tip
                                 Now pick ant from the SDK instead of the path
                                 Fixed summary link to the new plugin version
                                 Added report link to the new promoted plugin
                                 Create a dummy page if t does not already exists
                                 Extract ec_parameterForm
                                 Setting up JAVA_HOME to use the provided jre one in projectAsCode
2014-07-17  lrochette   Added CHANGELOG creation
2014-07-09  lrochette   Include projectAsCode option
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
2014-04-30  lrochette   Added a step to fix self reference to the project
*/

def procName= 'projectAsCode'
procedure procName,
  description: 'Create a plugin from a simple project',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'Initialization',
    description: 'Set up some job properties',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/Initialization.pl").text,
    shell: 'ec-perl'

  step 'setProjectProperty-ec_visbility',
    description: 'set the right properties to be able to see the project in the picketList',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/setProjectProperty-ec_visbility.pl").text,
    shell: 'ec-perl'

  step 'createConfigurationCode',
    condition: '$[/javascript (typeof(projects[\'$[Project]\'].configureCredentials) != "undefined") ;]',
    subprocedure: 'sub-pac_createConfigurationCode'
    actualParameter:[
      pluginName: '$[/myJob/pluginName]',
      Project: '$[Project]'
    ]

  step 'fixSelfReferences',
    description: 'Replace self references in states, schedules and steps to the current project by an empty String',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/fixSelfReferences.pl").text,
    condition: '$[fixSelfReferences]',
    shell: 'ec-perl'

  step 'exportProjectToServer',
    description: 'The export happens on the server',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/exportProjectToServer.pl").text,
    shell: 'ec-perl'

  step 'copyProjectToResource',
    description: 'Only use when resource is not local (or you get an error as the file is removed before being copied)',
    condition: '$[/javascript "$[SDKResource]" != "local"]',
    errorHandling: 'abortJob',
    subprocedure: 'Remote Copy - Native',
    subproject: '/plugins/EC-FileOps/project',
    actualParameter: [
      destinationFile: '$[directory]/project.xml',
      destinationResourceName: '$[SDKResource]',
      destinationWorkspaceName: 'default',
      sourceFile: '$[/server/Electric Cloud/dataDirectory]/logs/project.xml',
      sourceResourceName: 'local',
      sourceWorkspaceName: 'default'
    ]

  step 'copyProjectToDirectory',
    condition: '$[/javascript "$[SDKResource]" == "local"]',
    errorHandling: 'abortJob',
    resourceName: 'local',
    subprocedure: 'Copy',
    subproject: '/plugins/EC-FileOps/project',
    actualParameter: [
      destinationFile: '$[directory]/project.xml',
      replaceDestinationIfPreexists: '1',
      sourceFile: '$[/server/Electric Cloud/dataDirectory]/logs/project.xml'
    ]

  step 'deleteExportedProject',
    condition: '$[/javascript !$[disableCleanup] ]',
    resourceName: 'local',
    subprocedure: 'DeleteFile',
    subproject: '/plugins/EC-FileOps/project',
    actualParameter: [
      Path: '$[/server/Electric Cloud/dataDirectory]/logs/project.xml'
    ]

  step 'explodeProject',
    description: ''' Converts a Commander project into ProjectAsCode-ready set of files:
 - Steps:  project/<procedureName>-<stepName><.extension>
 - project/manifest.pl
 - project/project.xml.in''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/explodeProject.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

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
    resourceName: '$[SDKResource]',
    shell: 'ec-perl'

  step 'create_ec_setup.pl',
    description: '''set the right properties to be able to see the project in the picketList.
Procedure is added only if property pluginExpose is set''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_ec_setup_pl.pl").text,
    condition: '$[/javascript "$[overwrite]" == "true" ;]',
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

  step 'create_build.xml',
    description: 'create the build.xml',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_build_xml.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl'

  step 'create_CHANGELOG',
    description: 'create the CHANGELOG file',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_CHANGELOG.pl").text,
    condition: '$[/javascript "$[Comment]" != "" ]',
    resourceName: '$[SDKResource]',
    shell: 'ec-perl'

  step 'create_plugin.xml',
    description: 'create the META-INF/plugin.xml',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_plugin_xml.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl'

  step 'restore-ec_visibility',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/restore-ec_visibility.pl").text,
    shell: 'ec-perl'

  step 'createHelp.xml',
    description: '''if the property "help" exist for the project, use it to create the pages/help.xml.
If not and the fie does not already exist, create a "dummy" page to be filled later''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/createHelp_xml.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

  step 'createConfigure.xml',
    description: '''if the property "configure" exist for the project, use it to create the files:
  pages/configurations.xml
  pages/editConfiguration.xml
  pages/newConfiguration.xml

If not and the fie does not already exist, create a "dummy" page to be filled later''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/createConfigure_xml.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

  step 'create_cgi-bin_configuration_files',
    description: '''if the property "configure" exist for the project, create the files:
  cgi-bin/plugin.cgi
  cgi-bin/jobMonitor.cgi

If not and the fie does not already exist, create a "dummy" page to be filled later''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_cgi-bin_configuration_files.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

  step 'create_java_code',
    description: '''if the property "configure" exist for the project,
create the files in main/java/ecplugins/XXXX/client''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_java_code.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

  step 'create_ConfigurationManagement.gwt.xml',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/create_ConfigurationManagement_gwt_xml.pl").text,
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

  step 'buildPlugin',
    description: 'build plugin using ant',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/buildPlugin.pl").text,
    errorHandling: 'abortJob',
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]'

  step 'savePluginAsArtifactVersion',
    description: 'Let\'s save the plugin in the Artifact Repository',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/savePluginAsArtifactVersion.pl").text,
    condition: '$[createArtifact]',
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]/out'

  step 'installPlugin',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/installPlugin.pl").text,
    condition: '''$[/javascript "$[installPlugin]" == "true" ]''',
    errorHandling: 'abortProcedureNow',
    resourceName: '$[SDKResource]',
    shell: 'ec-perl',
    workingDirectory: '$[directory]/out'

  step 'promotePlugin',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/promotePlugin.pl").text,
    condition: '$[/javascript "$[promotePlugin]" == "true" ]',
    shell: 'ec-perl'
}
