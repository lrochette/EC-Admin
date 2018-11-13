import java.io.File

def procName= 'subPM-performance'

procedure procName,
  description: 'This is a procedure to test resource performance',
{
  formalParameter 'hostname',
    description: 'Name of the machine to test',
    required: '1',
    type: 'entry'

  formalParameter 'resource',
    description: 'Name of the resource',
    required: '0',
    type: 'entry'

  step 'performance',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/performance.pl").text,
    shell: 'ec-perl',
    workspaceName: '$[/javascript ("$[/resources/$[resource]/workspaceName]" == "")?"default": "$[/resources/$[resource]/workspaceName]"; ]',
    resource: '$[resource]'

  // Do not Display in the property picker
  property 'standardStepPicker', value: false
}
