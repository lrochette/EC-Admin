import java.io.File

def procName= 'findJobId'

procedure procName,
  description: '''A procedure to find the occurrences of jobId in sub-procedure parameters and command to help with 4.2 to 5.x+ migration
It will also find the project top level properties that could collide with deploy objects like applications or environments''',
  jobNameTemplate: '$[/myProject/scripts/jobTemplate]',
{
  formalParameter 'projectPattern',
    defaultValue: '',
    description: 'a SQL pattern to filter projects. Default is all projects.',
    required: '0',
    type: 'entry'

  step 'findCollidingProperties',
    description: 'Find project level properties that could collide with new Deploy objects',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/findCollidingProperties.pl").text,
    shell: 'ec-perl'

  step 'procedureCrawler',
    description: 'This step searches in top level project properties and procedures/steps',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/procedureCrawler.pl").text,
    shell: 'ec-perl'

  step 'workflowCrawler',
    description: 'This step searches in workflow and states',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/workflowCrawler.pl").text,
    shell: 'ec-perl'
}
