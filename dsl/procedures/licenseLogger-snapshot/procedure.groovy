import java.io.File

/*
Copyright 2016-2018 Electric-Cloud Inc.

Author: L. Rochette

History:
------------------------------------------------------------------------------
2018-06-18  lrochette  Convert to PluginWizard DSL format
2015-02-25  lrochette  Fixed Issue #15: name of the configuration PS should be
                       EC-Admin not plugin name and version
*/

def procName= 'licenseLogger-snapshot'

procedure procName,
  description: '''<html><b>Scheduled Procedure</b> - gathers and stores the
periodic snapshot of license usage</html>''',
  jobNameTemplate: '$[/plugins[EC-Admin]project/scripts/jobTemplate]',
{
  step 'getLicenseUsage',
    description: 'Perl script to log license usage statistics',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/getLicenseUsage.pl").text,
    errorHandling: 'abortJob',
    resourceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.resource) == "undefined")? "local" : server[\'EC-Admin\'].licenseLogger.config.resource ]',
    shell: 'ec-perl',
    timeLimit: '15',
    timeLimitUnits: 'minutes',
    workspaceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.workspace) == "undefined")? "default" : server[\'EC-Admin\'].licenseLogger.config.workspace ]'

  step 'cleanup',
    description: 'Cleans up old job records.',
    alwaysRun: '1',
    command: '$' + '[/myProject/scripts/licenseLogger/jobCleanup.pl]',
    condition: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.cleanpOldJobs) == "undefined")? "1" : server[\'EC-Admin\'].licenseLogger.config.cleanpOldJobs ]',
    resourceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.resource) == "undefined")? "local" : server[\'EC-Admin\'].licenseLogger.config.resource ]',
    shell: 'ec-perl',
    timeLimit: '5',
    timeLimitUnits: 'minutes',
    workspaceName: '$[/javascript (typeof(server[\'EC-Admin\'].licenseLogger.config.workspace) == "undefined")? "default" : server[\'EC-Admin\'].licenseLogger.config.workspace ]'
}
