import java.io.File

/*
Copyright 2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-18-2018  lrochette     Convert to PluginWizard DSL format
2014-02-27 Kate McCormack Adding setTimeout equal to 600 so the ec commands
                          won't time out
2013-12-17 lrochette      Add chmod after directory creation for cases when
                          server service and server agent service user are different.
2013-07-28 lochette       Add parameters to include or not ACLs and email notifiers
*/

def procName= 'saveProjects'

procedure procName,
  description: 'a framework to export projects.',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  emailNotifier 'backupFailed',
    condition: '''$[/javascript if(getProperty("outcome") == \'error\')
    true;
else
    false;]''',
    configName: 'default',
    destinations: '$' + '[/users/admin/email]',
    eventType: 'onCompletion',
    formattingTemplate: '''Subject:Project Backup Failed
Job  \'$[jobName]\'  from procedure  \'$[procedureName]\'  $[/myEvent/type]  - Commander notification

$[/server/ec_notifierTemplates/Html_JobTempl/body]'''

  step 'saveProjects',
    description: 'A procedure to export each project individually into a XML file for backup',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/saveProjects.pl").text,
    shell: 'ec-perl'
}
