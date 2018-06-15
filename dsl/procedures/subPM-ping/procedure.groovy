import java.io.File

def procName= 'subPM-ping'

procedure procName,
  description: 'This is a procedure to test ping answer time',
{
  formalParameter 'hostname',
    description: 'Name of the machine to test',
    required: '1',
    type: 'entry'

  formalParameter 'resource',
    description: 'Name of the resource',
    required: '0',
    type: 'entry'

  step 'ping', 
    command: new File(pluginDir, "dsl/procedures/$procName/steps/ping.pl").text,
    shell: 'ec-perl'

  // Do not Display in the property picker
  property 'standardStepPicker', value: false
}
