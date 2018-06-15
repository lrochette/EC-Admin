import java.io.File

def procName = 'generateDslTree'
procedure procName,
  description: "Export DSL code for use in PluginWizard structure",
{
  step 'genererateDslTree',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/generateDslTree.pl").text,
    shell: 'ec-perl'
}
