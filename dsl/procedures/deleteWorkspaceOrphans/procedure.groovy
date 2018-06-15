import java.io.File

def procName= 'deleteWorkspaceOrphans'

procedure procName,
  description: 'Procedure to crawl a workspace directory to find orphan jobs (directories without a matching job)',
  jobNameTemplate: '$[/myProject/scripts/jobTemplate]',
{
  step 'crawlWorkspace',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/crawlWorkspace.pl").text,
    shell: 'ec-perl',
    resourceName: '$[resource]'
}
