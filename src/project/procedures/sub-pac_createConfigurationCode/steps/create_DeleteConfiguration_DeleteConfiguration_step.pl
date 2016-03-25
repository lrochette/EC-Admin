$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

my $proc="DeleteConfiguration";
my $step="DeleteConfiguration";

#
# Create new procedure only if it does not exist yet
my ($ok, $json)=InvokeCommander("IgnoreError SuppressLog",
	'getStep', $project, $proc, $step);

if ($ok) {
  printf("Step \'$step\' already exists!\n");
  $ec->setProperty("summary", "\'$step\' already exists!");
  exit(0);
}

#
# Code of the command
#
my $command = sprintf(
'##########################
# deletecfg.pl
##########################

use ElectricCommander;
use ElectricCommander::PropDB;

use constant {
	SUCCESS => 0,
	ERROR   => 1,
};

my $opts;

my $PLUGIN_NAME = "$[pluginName]";
my $projName = "$%s]";

if (!defined $PLUGIN_NAME) {
    print "PLUGIN_NAME must be defined\n";
    exit ERROR;
}

# get an EC object
my $ec = new ElectricCommander();
$ec->abortOnError(0);

my $opts;
$opts->{config} = "$%s]";

if (!defined $opts->{config} || "$opts->{config}" eq "" ) {
    print "config parameter must exist and be non-blank\n";
    exit ERROR;
}

# check to see if a config with this name already exists before we do anything else
my $xpath = $ec->getProperty("/myProject/plugin_cfgs/$opts->{config}");
my $property = $xpath->findvalue("//response/property/propertyName");

if (!defined $property || "$property" eq "") {
    my $errMsg = "Error: A configuration named \'$opts->{config}\' does not exist.";
    $ec->setProperty("/myJob/configError", $errMsg);
    print $errMsg;
    exit ERROR;
}

$ec->deleteProperty("/myProject/plugin_cfgs/$opts->{config}");
$ec->deleteCredential($projName, $opts->{config});
exit SUCCESS;
',
	"[/myProject/projectName", "[config");

#
# create CreateConfiguration step
printf("  Create Step CreateConfiguration\n");
$ec->createStep($project, $proc, $step,
    {
    	description => "Delete a $[/myJob/pluginName] configuration",
        command => $command,
        postProcessor => "postp",
        timeLimit => 5,
        timeLimitUnits => "minutes",
        shell => "ec-perl"
    });



$[/myProject/scripts/perlLibJSON]




















