import java.io.File

def procName='cleanupCacheDirectory'
procedure procName,
  description: '''Clear out all stale artifacts from a given artifact cache.
Can be called manually on 1 resource or automatically on all''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
  resourceName: '$[resource]',
{
  step 'clearInvalidArtifactVersions',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/clearInvalidArtifactVersions.pl").text,
    shell: 'ec-perl'

  step 'traverseCacheDirectory',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/traverseCacheDirectory.pl").text,
    condition: '$[/javascript myJob.cacheDirectoryIsValid == \'1\']',
    errorHandling: 'failProcedure',
    shell: 'ec-perl'

  step 'timeBaseDeletion',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/timeBaseDeletion.pl").text,
    condition: '$[/javascript myJob.candidatesForDeletion == \'1\']',
    errorHandling: 'failProcedure',
    shell: 'ec-perl'
}
