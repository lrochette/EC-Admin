$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

my @propList= qw (createConfigForm editConfigForm);


foreach my $prop (@propList) {
	# do not overwrite an existing property
	if (getP("/projects/$project/ui_forms/$prop")) {
    	printf("Property ui_forms/$prop already exists!\n");
        next;
	}
    printf("Create property ui_forms/$prop\n");
    $ec->setProperty("/projects/$project/ui_forms/$prop",
    				getP("/myProject/pac_configurations/ui_forms/$prop"));
}

$[/myProject/scripts/perlLibJSON]





