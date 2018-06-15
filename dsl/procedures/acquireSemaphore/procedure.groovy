import java.io.File

def procName = 'acquireSemaphore'
procedure procName,
  description: "Acquire a token in order to limit access to a set of procedures",
{
  step 'acquireSemaphore',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/acquireSemaphore.pl").text,
    shell: 'ec-perl',
    resourceName: '$[serializationResource]'
}
