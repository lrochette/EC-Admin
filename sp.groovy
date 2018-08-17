
procedure 'saveProjects', {
  description = 'a framework to export projects.'
  jobNameTemplate = '$[/plugins[EC-Admin]/project/scripts/jobTemplate]'
  projectName = 'EC-Admin-3.1.1.666'
  resourceName = null
  timeLimitUnits = null
  workspaceName = null

  emailNotifier 'backupFailed', {
    condition = '''$[/javascript if(getProperty("outcome") == \'error\')
    true;
else
    false;]'''
    configName = 'default'
    destinations = '$[/users/admin/email]'
    eventType = 'onCompletion'
    formattingTemplate = '''Subject:Project Backup Failed
Job  \'$[jobName]\'  from procedure  \'$[procedureName]\'  $[/myEvent/type]  - Commander notification

$[/server/ec_notifierTemplates/Html_JobTempl/body]'''
  }

  formalParameter 'includeACLs', defaultValue: 'false', {
    description = 'If set to "true", the export will include ACLs.'
    expansionDeferred = '0'
    label = 'ACLs'
    orderIndex = null
    required = '0'
    type = 'checkbox'
  }

  formalParameter 'includeNotifiers', defaultValue: 'false', {
    description = 'If set to "true", the export will include email notifiers.'
    expansionDeferred = '0'
    label = 'Notifiers'
    orderIndex = null
    required = '0'
    type = 'checkbox'
  }

  formalParameter 'pathname', defaultValue: '/tmp', {
    description = 'Directory where to saved the XML files.'
    expansionDeferred = '0'
    label = 'Backup directory'
    orderIndex = null
    required = '1'
    type = 'entry'
  }

  formalParameter 'relocatable', defaultValue: 'true', {
    description = '''If set to "true", the export will not include object IDs, ACLs, system property sheets, create/modify times, owners, 
email notifiers or lastModifiedBy information, and the export file result will be much smaller than a normal export.'''
    expansionDeferred = '0'
    label = 'Relocatable'
    orderIndex = null
    required = '0'
    type = 'checkbox'
  }

  step 'saveProjects', {
    description = 'A procedure to export each project individually into a XML file for backup'
    alwaysRun = '0'
    broadcast = '0'
    command = '''#############################################################################
#
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

#
# Parameters
#
my $path="$[pathname]";
my $includeACLs="$[includeACLs]";
my $includeNotifiers="$[includeNotifiers]";
my $relocatable="$[relocatable]";

# Set the timeout to config value or 600 if not set
my $defaultTimeout = getP("/server/EC-Admin/cleanup/config/timeout");
$ec->setTimeout($defaultTimeout? $defaultTimeout : 600);

my $errorCount=0;
# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "getProjects");

# Create the directory
# chmod required for cases when the server agent user and the server user
# are different and the mask prevent the created directory to be written
# by the latter.
mkpath($path);
chmod 0777, $path;

foreach my $node ($xPath->findnodes(\'//project\')) {
  my $pName=$node->{\'projectName\'};
  my $pluginName=$node->{\'pluginName\'};

  # skip plugins
  next if ($pluginName ne "");
  printf("Saving Project: %s\\n", $pName);
  my ($success, $xPath, $errMsg, $errCode) = InvokeCommander("SuppressLog", "export", $path."/$pName".".xml",
  					{ \'path\'=> "/projects/".$pName,
                                          \'relocatable\' => $relocatable,
                                          \'withAcls\'    => $includeACLs,
                                          \'withNotifiers\'=>$includeNotifiers});
  if (! $success) {
    printf("  Error exporting %s", $pName);
    printf("  %s: %s\\n", $errCode, $errMsg);
    $errorCount++;
  }
}
exit($errorCount);

$[/myProject/scripts/perlLibJSON]
'''
    condition = null
    errorHandling = 'failProcedure'
    exclusiveMode = 'none'
    logFileName = null
    parallel = '0'
    postProcessor = null
    precondition = null
    projectName = 'EC-Admin-3.1.1.666'
    releaseMode = 'none'
    resourceName = null
    shell = 'ec-perl'
    subprocedure = null
    subproject = null
    timeLimitUnits = null
    workingDirectory = null
    workspaceName = null
  }

  step 'saveAllObjects', {
    description = ''
    alwaysRun = '0'
    broadcast = '0'
    command = null
    condition = ''
    errorHandling = 'failProcedure'
    exclusiveMode = 'none'
    logFileName = null
    parallel = '0'
    postProcessor = null
    precondition = ''
    projectName = 'EC-Admin-3.1.1.666'
    releaseMode = 'none'
    resourceName = ''
    shell = null
    subprocedure = 'saveAllObjects'
    subproject = ''
    timeLimit = ''
    timeLimitUnits = 'minutes'
    workingDirectory = null
    workspaceName = ''
    actualParameter '''caseSensitive''', ''''''
    actualParameter '''exportDeploy''', '''false'''
    actualParameter '''exportGateways''', '''false'''
    actualParameter '''exportGroups''', '''false'''
    actualParameter '''exportResourcePools''', '''false'''
    actualParameter '''exportResources''', '''false'''
    actualParameter '''exportSteps''', '''false'''
    actualParameter '''exportUsers''', '''false'''
    actualParameter '''exportWorkspaces''', '''false'''
    actualParameter '''exportZones''', '''false'''
    actualParameter '''includeACLs''', '''true'''
    actualParameter '''includeNotifiers''', '''false'''
    actualParameter '''pathname''', '''/tmp/BACKUP'''
    actualParameter '''pattern''', ''''''
    actualParameter '''relocatable''', '''true'''
  }

  // Custom properties

  property 'ec_customEditorData', {

    // Custom properties

    property 'parameters', {

      // Custom properties

      property 'includeACLs', {

        // Custom properties
        checkedValue = 'true'
        formType = 'standard'
        initiallyChecked = '0'
        uncheckedValue = 'false'
      }

      property 'includeNotifiers', {

        // Custom properties
        checkedValue = 'true'
        formType = 'standard'
        initiallyChecked = '0'
        uncheckedValue = 'false'
      }

      property 'pathname', {

        // Custom properties
        formType = 'standard'
      }

      property 'relocatable', {

        // Custom properties
        checkedValue = 'true'
        formType = 'standard'
        initiallyChecked = '1'
        uncheckedValue = 'false'
      }
    }
  }
  ec_parameterForm = '''<editor> 
    <formElement> 
        <label>Backup directory</label>	
        <property>pathname</property>	
        <documentation>Directory where to saved the XML files.</documentation> 
        <type>entry</type>	
        <value>/tmp</value> 
	    <required>1</required> 
    </formElement> 
    <formElement> 
        <label>Relocatable</label>	
        <property>relocatable</property> 
        <documentation>If set to "true", the export will not include object IDs, ACLs, system property sheets, create/modify times, owners, 
email notifiers or lastModifiedBy information, and the export file result will be much smaller than a normal export.</documentation> 
        <type>checkbox</type>	
        <checkedValue>true</checkedValue> 
        <uncheckedValue>false</uncheckedValue> 
        <initiallyChecked>1</initiallyChecked> 
        <value>true</value>	
    </formElement> 
    <formElement> 
        <label>ACLs</label>	
        <property>includeACLs</property> 
        <documentation>If set to "true", the export will include ACLs.</documentation> 
        <type>checkbox</type>	
        <checkedValue>true</checkedValue> 
        <uncheckedValue>false</uncheckedValue> 
        <initiallyChecked>0</initiallyChecked> 
        <value>false</value>	
    </formElement> 
    <formElement> 
        <label>Notifiers</label>	
        <property>includeNotifiers</property> 
        <documentation>If set to "true", the export will include email notifiers.</documentation> 
        <type>checkbox</type>	
        <checkedValue>true</checkedValue> 
        <uncheckedValue>false</uncheckedValue> 
        <initiallyChecked>0</initiallyChecked> 
        <value>false</value>	
    </formElement> 
</editor> '''
}
