$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

my $proc="createConfiguration";
my $step="createAndAttachCredential";

#
# Create new procedure only if it does not exist yet
my ($ok, $json)=InvokeCommander("IgnoreError SuppressLog",
	'getStep', $project, $proc, $step);

if ($ok) {
  printf("Step \'$step\' already exists!\n");
  $ec->setProperty("summary", "\'$step\' already exists!");
  exit(0);
}

# Properties to be expanded at runtime are passed as strings
# to prevent immediate substitution
# aka: printf("$%s]", "[/myJob/foo");

my $command=sprintf(
'##########################
# createAndAttachCredential.pl
##########################

use ElectricCommander;

use constant {
	SUCCESS => 0,
	ERROR   => 1,
};

my $ec = new ElectricCommander();
$ec->abortOnError(0);

my $credName = "$%s]";
my $xpath = $ec->getFullCredential("credential");
my $userName = $xpath->findvalue("//userName");
my $password = $xpath->findvalue("//password");

# Create credential
my $projName = "$%s]";

$ec->deleteCredential($projName, $credName);
$xpath = $ec->createCredential($projName, $credName, $userName, $password);
my $errors = $ec->checkAllErrors($xpath);

# Give config the credential real name
my $configPath = "/projects/$projName/plugin_cfgs/$credName";
$xpath = $ec->setProperty($configPath . "/credential", $credName);
$errors .= $ec->checkAllErrors($xpath);

# Give job launcher full permissions on the credential
my $user = "$%s]";
$xpath = $ec->createAclEntry("user", $user,
    {projectName => $projName,
     credentialName => $credName,
     readPrivilege => allow,
     modifyPrivilege => allow,
     executePrivilege => allow,
     changePermissionsPrivilege => allow});
$errors .= $ec->checkAllErrors($xpath);

## Attach credential to steps that will need it
    $xpath = $ec->attachCredential($projName, $credName,
    {procedureName => "XXXXX",
     stepName => "XXXXX"});
    $errors .= $ec->checkAllErrors($xpath);


#if errors
    if ("$errors" ne "") {
        # Cleanup the partially created configuration we just created
        $ec->deleteProperty($configPath);
        $ec->deleteCredential($projName, $credName);
        my $errMsg = "Error creating configuration credential: " . $errors;
        $ec->setProperty("/myJob/configError", $errMsg);
        print $errMsg;
        exit ERROR;
    }
',
"[/myJob/config", "[/myProject/projectName", "[/myJob/launchedByUser");

#
# create CreateAndAttachCredential step
printf("  Create Step CreateAndAttachCredential\n");
printf("      You NEED to edit this step to reflect the name of your procedures and steps that need creedentials attached\n");
$ec->createStep($project, $proc, $step,
    {
        command => $command,
        shell => "ec-perl"
    });

$ec->setProperty("summary", "YOU NEED TO MODIFY CreateConfiguration:CreateAndAttachCredential. See help page for details!");
$ec->setProperty("outcome", "warning");

$[/myProject/scripts/perlLibJSON]






