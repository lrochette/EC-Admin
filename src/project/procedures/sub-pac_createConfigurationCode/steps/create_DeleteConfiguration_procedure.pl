$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

my @propList= qw (createConfigForm editConfigForm);
my $proc="DeleteConfiguration";

#
# Create new procedure only if it does not exist yet
my ($ok, $json)=InvokeCommander("IgnoreError SuppressLog",
	'getProcedure', $project, $proc);

if ($ok) {
  printf("Procedure \'$proc\' already exists!\n");
  $ec->setProperty("summary", "\'$proc\' already exists!");
  exit(0);
}

printf("Create Procedure $proc\n");
$ec->createProcedure($project, $proc, 
	{
    	description => "Created by EC-Admin to manage credential configuration"
    });

#
# Create parameter config
printf("  Create Parameter config\n");
$ec->createFormalParameter($project, $proc, "config",
	{
    	description => "Configuration Name", 
        type => "entry",
        required => 1
    });


$[/myProject/scripts/perlLibJSON]








