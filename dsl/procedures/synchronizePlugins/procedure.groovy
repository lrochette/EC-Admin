import java.io.File

def procName = 'synchronizePlugins'
procedure procName,
  description: 'A procedure to synchronize plugins between the server and a resource. Plugins are uploaded first as artifacts and downloaded on the resource if they do not already exist.',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{

  step 'uploadPlugins',
    description: 'upload all plugins in the artifact Repository',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/uploadPlugins.pl").text,
    shell: 'ec-perl'

  step 'downloadPlugins',
    description: 'Parse all plugins artifact and retrieve the latest version in the plugin directory if it is not already there',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/downloadPlugins.pl").text,
    resourceName: '$[agent]',
    shell: 'ec-perl'
}
