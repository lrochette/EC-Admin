import java.io.File

def procName= 'artifactsCleanup'
procedure procName,
  description: '''Delete Artifacts and clean caches.
A resource matching the Repository server is required or some steps will be skipped.''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'deleteArtifactVersions',
    description: 'Script to delete old Artifact Versions',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/deleteArtifactVersions.pl").text,
    shell: 'ec-perl'

  step 'dynamicCleanRepoProcedure',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/dynamicCleanRepoProcedure.pl").text,
    shell: 'ec-perl'

  step 'dynamicCacheCleaningProcedure',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/dynamicCacheCleaningProcedure.pl").text,
    shell: 'ec-perl'
}
