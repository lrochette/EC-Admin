import java.io.File

def procName= 'subPM-jobStats'

procedure procName,
  jobNameTemplate: '$[/myProject/scripts/jobTemplate]',
{
  formalParameter 'debugMode',
    defaultValue: '0',
    description: 'debug mode',
    required: '0',
    type: 'checkbox'

  formalParameter 'number',
    defaultValue: '1000',
    description: 'Number of jobSteps to evaluate',
    required: '0',
    type: 'entry'

  step 'jobStats',
    description: 'A step to gather stats about jobs',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/jobStats.pl").text,
    shell: 'ec-perl'

  // Do not Display in the property picker
  property 'standardStepPicker', value: false
}
