import java.io.File

def procName= 'artifactsCleanup_byQuantity'

procedure procName,
  description: '''Delete Artifact Versions, keeping only X by Artifact ; thenclean caches.
A resource matching the Repository server is required or some steps will be skipped.''',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'deleteAV',
    description: 'Script to delete old Artifact Versions per Artifact',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/deleteAV.pl").text,
    shell: 'ec-perl'

  step 'dynamicCleanRepoProcedure',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/dynamicCleanRepoProcedure.pl").text,
    condition: '$[executeDeletion]',
    errorHandling: 'failProcedure',
    shell: 'ec-perl'

  step 'dynamicCacheCleaningProcedure', 
    command: new File(pluginDir, "dsl/procedures/$procName/steps/dynamicCacheCleaningProcedure.pl").text,
    condition: '$[executeDeletion]',
    shell: 'ec-perl'
}
