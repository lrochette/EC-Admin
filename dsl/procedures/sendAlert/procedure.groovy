import java.io.File

def procName='sendAlert'

procedure procName,
  description: 'This procedure allows you to send an email alert to all the users registered in the database',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
{
  step 'sendAlert',
    description: 'get the list of users and send an email',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/sendAlert.pl").text,
    shell: 'ec-perl'
}
