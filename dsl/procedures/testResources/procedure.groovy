import java.io.File

def procName = 'testResources'
procedure procName,
  description: 'Test either all resources in the system or all resources in a pool to see if they\'re alive, and run a test "hello world" command on those that are alive.',
{
  step 'Iterate',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/Iterate.pl").text,
    postProcessor: 'postp',
    shell: 'ec-perl'
}
