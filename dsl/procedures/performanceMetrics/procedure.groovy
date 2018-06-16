import java.io.File

/*
Changelog:
--------------
 06-15-2018  lrochette    Transform to PluginWizard (DSL) format
 04-09-2015  lrochette    Replaced some findObjects by countObjects
 08-09-2013  lrochette    Fixed bug on Free available RAM with European numbers
 08-30-2013  lrochette    Added fsutil error management
 08-30-2013  lrochette    Added a cleanup step for the disk performance temporary file
 12-21-2013  lrochette    Added license usage information
 04-16-2014  lrochette    Fixed subprocedure call to myProject instead of a fixed call
 04-18-2014  lrochette    Fixed with resource default  workspace not being used in dynamic steps'''
*/

def procName= 'performanceMetrics'

procedure procName,
  description: 'Performance diagnostics for EC server and agents',
  jobNameTemplate: '$[/plugins[EC-Admin]/project/scripts/jobTemplate]',
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

  step 'licenseUsage',
    description: 'Display information about license usage.',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/licenseUsage.pl").text,
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

  step 'deploymentSize',
    subprocedure: 'subPM-deploymentSize',
    subproject: '$[/myProject/projectName]'

  step 'writeDiskPerformance',
    description: 'Check theDisk Performance for the EC server',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/writeDiskPerformance.pl").text,
    shell: 'ec-perl'

  step 'readDiskPerformance',
    description: 'Check theDisk Performance for the EC server',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/readDiskPerformance.pl").text,
    shell: 'ec-perl'

  step 'localUsage',
    subprocedure: 'subPM-localUsage',
    subproject: '$[/myProject/projectName]',
    actualParameter:  [
      debugMode: "0",
      number: "5000"
    ]

  step 'Performance',
    description: '''Run a performance time on each resource
Test is from http://xahlee.info/UnixResource_dir/sultra_skami.html''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/Performance.pl").text,
    shell: 'ec-perl'

  step 'databasePerformance',
    description: 'Create a bunch of steps to check performance of the DB',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/databasePerformance.pl").text,
    shell: 'ec-perl'

  step 'PingTime',
    description: 'Check the ping times from  the EC server to the agents',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/PingTime.pl").text,
    shell: 'ec-perl'

  step 'cleanDiskPerformanceTemporaryFile',
    resourceName: 'local',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/cleanDiskPerformanceTemporaryFile.pl").text,
    shell: 'ec-perl'
}
