import java.io.File

/*
Changelog:
--------------
 07-03-2018  lrochette   Split core metrics in its own sub-procedure for easier testing
*/

def procName= 'subPM-core'

procedure procName,
  description: 'Core metrics for EC server',
  jobNameTemplate: '$[/myProject/scripts/jobTemplate]',
{
  step 'serverMemoryAmount',
    description: '''Check the amount of memory for the EC server
Default values:
Bad: < 8 GB
Good: Between 8 and 12 GB
Best: More than 12 GB''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/serverMemoryAmount.pl").text,
    resourceName: 'local',
    shell: 'ec-perl'

  step 'freeMemory',
    description: '''Check the amount of  free memory for the EC server
Information only''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/freeMemory.pl").text,
    resourceName: 'local',
    shell: 'ec-perl'

  step 'diskSpaceAvailable',
    description: '''Check the amount of  available disk space for the EC server
Information only''',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/diskSpaceAvailable.pl").text,
    shell: 'ec-perl'

  step 'javaHeap',
    description: '''Report Java size information''',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/javaHeap.pl").text,
    shell: 'ec-perl'

  step 'numberOfCores',
    description: '''Check the number of cores for the EC server
Default values:
Bad: < 4
Good: Between 4 and 6
Best: More than 6''',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/numberOfCores.pl").text,
    shell: 'ec-perl'

  step 'serverCpuSpeed',
    description: '''Check the CPU speed for the EC server
Default values:
Bad: < 1.5 GHz
Good: Between 1.5 and 2 GHz
Best: More than 2 GHz''',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/serverCpuSpeed.pl").text,
    shell: 'ec-perl'

  step 'databaseType',
    description: '''Check the Database type for the EC server
Default values:
Bad: H2 or mariadb
Good: mysql
Best: mssql or oracle''',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/databaseType.pl").text,
    shell: 'ec-perl'

    // Do not Display in the property picker
    property 'standardStepPicker', value: false
}
