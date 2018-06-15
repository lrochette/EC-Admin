import java.io.File

def procName = 'agentMemoryConfiguration'
procedure 'agentMemoryConfiguration', {
  description = '''A procedure to modify the java memory setting of an agent.
# Specify java heap size in percentage OR mb.

# Initial Java Heap Size (in %)
#wrapper.java.initmemory.percent=15

# Initial Java Heap Size (in mb)
wrapper.java.initmemory=256

# Maximum Java Heap Size (in %)
#wrapper.java.maxmemory.percent=15

# Maximum Java Heap Size (in mb)
wrapper.java.maxmemory=512
'''
  jobNameTemplate = ''
  projectName = 'EC-Admin'
  resourceName = ''
  timeLimit = ''
  timeLimitUnits = 'minutes'
  workspaceName = ''

  formalParameter 'agent', defaultValue: '', {
    description = ''
    expansionDeferred = '0'
    label = null
    orderIndex = null
    required = '1'
    type = 'entry'
  }

  formalParameter 'initMemory', defaultValue: '256', {
    description = 'a value in mb or a %'
    expansionDeferred = '0'
    label = null
    orderIndex = null
    required = '1'
    type = 'entry'
  }

  formalParameter 'maxMemory', defaultValue: '512', {
    description = 'a number in mb or a %'
    expansionDeferred = '0'
    label = null
    orderIndex = null
    required = '1'
    type = 'entry'
  }

  formalParameter 'restartAgent', defaultValue: 'true', {
    description = 'On Linux the agent service is restarted, on Windows the box is rebooted.'
    expansionDeferred = '0'
    label = null
    orderIndex = null
    required = '0'
    type = 'checkbox'
  }

  step 'modifyWrapper', {
    description = 'Modify the wrapper.conf'
    alwaysRun = '0'
    broadcast = '0'
    command = '''#############################################################################
#
#  modifyWrapper -- Script to change the memory setting of the Java agent.
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################
use File::Copy;

$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $initMemory = "$[initMemory]";
my $maxMemory  = "$[maxMemory]";

#############################################################################
#
#  Global variables
#
#############################################################################
my $wrapperFile= "$ENV{COMMANDER_DATA}/conf/agent/wrapper.conf";
my @out=();       # the modified set of lines
my $line;
my ($initMemPercentComment, $initMemPercentValue) = (\'#\', 15);
my ($initMemMbComment,      $initMemMbValue)      = (\'#\', 16);
my ($maxMemPercentComment,  $maxMemPercentValue)  = (\'#\', 15);
my ($maxMemMbComment,       $maxMemMbValue)       = (\'#\', 64);

#
# Check for correctness in the data
#
if ($initMemory =~ /^\\s*(\\d+)\\s*(%?)\\s*$/) {
  my ($value, $percent)=($1, ($2 eq \'%\')?1:0);
  printf("Init: %d, percent: %s\\n", $value, $percent);
  if ($percent) {
    $initMemPercentComment=\'\';
    $initMemPercentValue=$value;
  } else {
    $initMemMbComment=\'\';
    $initMemMbValue=$value;
  }
} else {
  printf("Error: the init memory parameter should be a number followed optionally by %%: %s\\n", $initMemory);
  exit(1);
}

if ($maxMemory =~ /^\\s*(\\d+)\\s*(%?)\\s*$/) {
  my ($value, $percent)=($1, ($2 eq \'%\')?1:0);
  printf("Max: %d, percent: %s\\n", $value, $percent);
  if ($percent) {
    $maxMemPercentComment=\'\';
    $maxMemPercentValue=$value;
  } else {
    $maxMemMbComment=\'\';
    $maxMemMbValue=$value;
  }
} else {
  printf("Error: the max memory parameter should be a number followed optionally by %%: %s\\n", $maxMemory);
  exit(1);
}
copy($wrapperFile,"${wrapperFile}_$[/timestamp YYYY-MM-dd]") or die "Copy failed: $!";

open(my $FH, "< $wrapperFile") || die ("Cannot open $wrapperFile\\n");
my @lines=<$FH>;
close($FH);

while (defined($line=shift(@lines))) {
  # looking for specific line indiacating start of the block
  if ($line =~ /Specify java heap size in percentage OR mb/) {
    # now write the new block
    push (@out, $line);
    my $block=sprintf("
# Initial Java Heap Size (in %)
%swrapper.java.initmemory.percent=%d

# Initial Java Heap Size (in mb)
%swrapper.java.initmemory=%d

# Maximum Java Heap Size (in %)
%swrapper.java.maxmemory.percent=%d

# Maximum Java Heap Size (in mb)
%swrapper.java.maxmemory=%d

",
    $initMemPercentComment, $initMemPercentValue,
    $initMemMbComment,      $initMemMbValue,
    $maxMemPercentComment,  $maxMemPercentValue,
    $maxMemMbComment,       $maxMemMbValue,
    );
    push(@out, $block);

    # Now skip the rest of the block until we get to the comment line
    do {
      $line=shift(@lines);
    } while ($line !~ /#\\*+/);
    push (@out, $line);
  } else {
        push (@out, $line);
    }
}

open(my $FH, "> $wrapperFile") || die ("Cannot open $wrapperFile\\n");
print $FH @out;
close($FH);

if ($osIsWindows) {
  $ec->setProperty("/myJob/platform", "Windows");
} else {
  $ec->setProperty("/myJob/platform", "Linux");
}














'''
    condition = ''
    errorHandling = 'abortProcedure'
    exclusiveMode = 'none'
    logFileName = ''
    parallel = '0'
    postProcessor = 'postp'
    precondition = ''
    projectName = 'EC-Admin'
    releaseMode = 'none'
    resourceName = '$[agent]'
    shell = 'ec-perl'
    subprocedure = null
    subproject = null
    timeLimit = ''
    timeLimitUnits = 'minutes'
    workingDirectory = ''
    workspaceName = ''
  }

  step 'restartAgentLinux', {
    description = '''restart the agent.
The agent stops but does not restart'''
    alwaysRun = '0'
    broadcast = '0'
    command = '''#############################################################################
#
#  restartAgent -- Script to possibly restart an agent.
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################

$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

if ($osIsWindows) {
  $ec->setProperty("summary", "Rebooting the agent");
  system("shutdown /r /c \\"ELectricFlow: modification of the Java Heap memory settings\\" /t 15")
} else {
  $ec->setProperty("summary", "Restarting the agent service");
  system("echo \'/etc/init.d/commanderAgent start\' | at now + 1 minute");
  system("/etc/init.d/commanderAgent stop");
}














'''
    condition = '$[/javascript ("$[restartAgent]" == "true") && ("$[/myJob/platform]" == "linux") ]'
    errorHandling = 'failProcedure'
    exclusiveMode = 'none'
    logFileName = ''
    parallel = '0'
    postProcessor = ''
    precondition = ''
    projectName = 'EC-Admin'
    releaseMode = 'none'
    resourceName = '$[agent]'
    shell = 'ec-perl'
    subprocedure = null
    subproject = null
    timeLimit = ''
    timeLimitUnits = 'minutes'
    workingDirectory = ''
    workspaceName = ''
  }

  step 'restartAgentWindows', {
    description = '''restart the agent.
The agent stops but does not restart'''
    alwaysRun = '0'
    broadcast = '0'
    command = '''#############################################################################
#
#  restartAgent -- Script to possibly restart an agent.
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################

if ($osIsWindows) {
  $ec->setProperty("summary", "Rebooting the agent");
  system("shutdown /r /c \\"ELectricFlow: modification of the Java Heap memory settings\\" /t 15")
}














'''
    condition = '$[/javascript ("$[restartAgent]" == "true") && ("$[/myJob/platform]" == "windows") ]'
    errorHandling = 'failProcedure'
    exclusiveMode = 'none'
    logFileName = ''
    parallel = '0'
    postProcessor = ''
    precondition = ''
    projectName = 'EC-Admin'
    releaseMode = 'none'
    resourceName = '$[agent]'
    shell = 'powershell  "& \'{0}.ps1\'"'
    subprocedure = null
    subproject = null
    timeLimit = ''
    timeLimitUnits = 'minutes'
    workingDirectory = ''
    workspaceName = ''
  }

  step 'waitForAgentToGoDown', {
    description = 'This gives time to the agent to go down'
    alwaysRun = '0'
    broadcast = '0'
    command = '''sleep(30)














'''
    condition = ''
    errorHandling = 'failProcedure'
    exclusiveMode = 'none'
    logFileName = ''
    parallel = '0'
    postProcessor = ''
    precondition = ''
    projectName = 'EC-Admin'
    releaseMode = 'none'
    resourceName = ''
    shell = 'ec-perl'
    subprocedure = null
    subproject = null
    timeLimit = ''
    timeLimitUnits = 'minutes'
    workingDirectory = ''
    workspaceName = ''
  }

  step 'waitForAgentToComeBack', {
    description = 'The step will be blocked until the agent is available again'
    alwaysRun = '0'
    broadcast = '0'
    command = '''echo "Hello world"














'''
    condition = '$[agent]'
    errorHandling = 'failProcedure'
    exclusiveMode = 'none'
    logFileName = ''
    parallel = '0'
    postProcessor = ''
    precondition = ''
    projectName = 'EC-Admin'
    releaseMode = 'none'
    resourceName = '$[agent]'
    shell = ''
    subprocedure = null
    subproject = null
    timeLimit = ''
    timeLimitUnits = 'minutes'
    workingDirectory = ''
    workspaceName = ''
  }

  // Custom properties

  property 'ec_customEditorData', {

    // Custom properties

    property 'parameters', {

      // Custom properties

      property 'agent', {

        // Custom properties
        formType = 'standard'
      }

      property 'initMemory', {

        // Custom properties
        formType = 'standard'
      }

      property 'maxMemory', {

        // Custom properties
        formType = 'standard'
      }

      property 'restartAgent', {

        // Custom properties
        checkedValue = 'true'
        formType = 'standard'
        initiallyChecked = '1'
        uncheckedValue = 'false'
      }
    }
  }
  exposeToPlugin = '1'
}
