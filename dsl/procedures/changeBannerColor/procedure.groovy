import java.io.File

def procName= 'changeBannerColor'

procedure procName,
  description: 'A procedure to change the color of the banner to easily identify your multiple servers (DEV vs. PROD)',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'check',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/check.pl").text,
    shell: 'ec-perl',
    resourceName: '$[webResource]',
    errorHandling: 'abortProcedure'

  step 'updateCSSPlatform',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/updateCSSPlatform.pl").text,
    shell: 'ec-perl',
    resourceName: '$[webResource]'

  step 'updateCSSDeploy',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/updateCSSDeploy.pl").text,
    shell: 'ec-perl',
    resourceName: '$[webResource]'

  step 'copyLogoFilePlatform',
    subprocedure: 'Copy',
    subproject: '/plugins/EC-FileOps/project',
    resourceName: '$[webResource]',
    actualParameter: [
      destinationFile: '$[/server/Electric Cloud/installDirectory]/apache/htdocs/commander/images/logo.gif',
      sourceFile: '$[/javascript ("$[logoFile]" == "")? "$[/server/settings/pluginsDirectory]/$[/myProject]/htdocs/$[logo]" : "$[logoFile]" ;]',
      replaceDestinationIfPreexists: '1'
    ]

  step 'copyLogoFileDeploy',
    subprocedure: 'Copy',
    subproject: '/plugins/EC-FileOps/project',
    resourceName: '$[webResource]',
    actualParameter: [
      destinationFile: '$[/server/Electric Cloud/installDirectory]/apache/htdocs/flow/public/app/assets/img/logo.png',
      sourceFile: '$[/javascript ("$[logoFile]" == "")? "$[/server/settings/pluginsDirectory]/$[/myProject]/htdocs/$[logo]" : "$[logoFile]" ;]',
      replaceDestinationIfPreexists: '1'
    ]
}
