import java.io.File

def procName= 'subPM-localUsage'
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


  step 'localUsage',
    description: '''A step to find out the percentage of steps and time spend running on local. Best practices call for jobs to run on remote agents''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/localUsage.pl").text,
    shell: 'ec-perl'

    // Do not Display in the property picker
    property 'standardStepPicker', value: false
}
