import java.io.File

def procName= 'deleteObjects'

procedure procName,
  description: '''A procedure to quickly delete jobs or workflows older than a
specified number of days. It will NOT delete associated workspace job
directories. This is for customers with huge job or workflow database''',
{
  step 'Delete',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/Delete.pl").text,
    shell: 'ec-perl',
    postProcessor: 'postp'
}
