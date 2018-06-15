import java.io.File

def procName= 'changeBannerColor'

procedure procName,
  description: 'A procedure to change the color of the banner to easily identify your multiple servers (DEV vs. PROD)',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'updateCSS',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/updateCSS.pl").text,
    shell: 'ec-perl',
    resourceName: '$[webResource]'

  step 'copyLogoFile',
    subprocedure: 'Remote Copy - Native',
    subproject: '/plugins/EC-FileOps/project',
    actualParameter: [
       destinationFile: '$[/server/Electric Cloud/installDirectory]/apache/htdocs/commander/images/logo.gif',
      destinationResourceName: '$[webResource]',
      destinationWorkspaceName: 'default',
      sourceFile: '$[/javascript ("$[logoFile]" == "")? "$[/server/settings/pluginsDirectory]/$[/myProject]/htdocs/$[logo]" : "$[logoFile]" ;]',
      sourceResourceName: 'local',
      sourceWorkspaceName: 'default'
    ]
}
