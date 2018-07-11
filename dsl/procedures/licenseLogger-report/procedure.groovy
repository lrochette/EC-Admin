import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
06-18-2018  lrochette    Convert to PluginWizard DSL format
*/

def procName= 'licenseLogger-report'

procedure procName,
  description: '''<html><b>Scheduled Procedure</b> - report on license usage
summary and supporting detail</html>''',
  jobNameTemplate: '$[/plugins[EC-Admin]project/scripts/jobTemplate]',
{
  formalParameter 'logName',
    description: 'Name of log to be processed. Default is the log corresponding to the previous period (i.e. for monthly logs, the default is to process last month\'s log)',
    required: '0',
    type: 'entry'

  formalParameter 'sendEmail',
    defaultValue: 'true',
    description: 'Send email?',
    required: '1',
    type: 'checkbox'

  step 'summarizeLicenseUsage',
    description: 'Perl script to identify and summarize a log file containing license usage statistics',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/summarizeLicenseUsage.pl").text,
    errorHandling: 'abortJob',
    resourceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.resource) == "undefined")? "local" : server[\'EC-Admin\'].licenseLogger.config.resource ]',
    shell: 'ec-perl',
    workspaceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.workspace) == "undefined")? "default" : server[\'EC-Admin\'].licenseLogger.config.workspace ]'

  step 'cleanup',
    description: 'Cleans up old job records.',
    command: '$' + '[/myProject/scripts/licenseLogger/jobCleanup.pl]',
    condition: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.cleanpOldJobs) == "undefined")? "1" : server[\'EC-Admin\'].licenseLogger.config.cleanpOldJobs ]',
    resourceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.resource) == "undefined")? "local" : server[\'EC-Admin\'].licenseLogger.config.resource ]',
    shell: 'ec-perl',
    timeLimit: '5',
    timeLimitUnits: 'minutes',
    workspaceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.workspace) == "undefined")? "default" : server[\'EC-Admin\'].licenseLogger.config.workspace ]'
}
