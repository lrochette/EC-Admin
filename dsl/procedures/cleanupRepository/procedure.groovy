import java.io.File

def procName= 'cleanupRepository'
procedure procName,
  description: '''Clear out all stale artifacts from a repository\'s backing store.
This procedure can be run on an individual repository or can be called on all repositories by "Artifact Cleanup"''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
  resourceName: '$[resource]',
{
  step 'clearInvalidArtifactVersions',
    description: '''Check the environment variable COMMANDER_DATA, then check for a repository server.properties relative to this directory. Error out if the properties file can\'t be found, otherwise parse it for the backing store location. Once we have the backing store, call cleanupRepository on that directory.''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/clearInvalidArtifactVersions.pl").text,
    resourceName: '$[resource]',
    shell: 'ec-perl'
}
