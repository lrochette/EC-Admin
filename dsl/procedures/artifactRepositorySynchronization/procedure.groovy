import java.io.File

def procName= 'artifactRepositorySynchronization'
procedure procName,
  description: '''Syncs the contents of 2 repositories no matter what is the backing store.
Each AV backing store  to synchronize is downloaded from the source repo on the resource and uploaded to the target repo''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'syncRepo',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/syncRepo.pl").text,
    resourceName: '$[syncResource]',
    shell: 'ec-perl'
}
