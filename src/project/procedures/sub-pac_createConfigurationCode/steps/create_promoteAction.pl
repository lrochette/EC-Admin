$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

# do not overwrite an existing property
if (getP("/projects/$project/promoteAction")) {
    printf("Property promoteAction already exists!\n");
    $ec->setProperty("summary", "Property promoteAction already exists");
    exit(0);
}

printf("Create property promoteAction\n");
my $prop=sprintf(
'# upgrade action
if ($upgradeAction eq "upgrade") {
    my $query = $commander->newBatch();
    my $newcfg = $query->getProperty(
        "/plugins/$pluginName/project/plugin_cfgs");
    my $oldcfgs = $query->getProperty(
        "/plugins/$otherPluginName/project/plugin_cfgs");
	my $creds = $query->getCredentials("\$%s]");

	local $self->{abortOnError} = 0;
    $query->submit();

    # if new plugin does not already have cfgs
    if ($query->findvalue($newcfg,"code") eq "NoSuchProperty") {
        # if old cfg has some cfgs to copy
        if ($query->findvalue($oldcfgs,"code") ne "NoSuchProperty") {
            $batch->clone({
                path => "/plugins/$otherPluginName/project/plugin_cfgs",
                cloneName => "/plugins/$pluginName/project/plugin_cfgs"
            });
        }
    }
	
	# Copy configuration credentials and attach them to the appropriate steps
    my $nodes = $query->find($creds);
    if ($nodes) {
        my @nodes = $nodes->findnodes("credential/credentialName");
        for (@nodes) {
            my $cred = $_->string_value;

            # Clone the credential
            $batch->clone({
                path => "/plugins/$otherPluginName/project/credentials/$cred",
                cloneName => "/plugins/$pluginName/project/credentials/$cred"
            });

            # Make sure the credential has an ACL entry for the new project principal
            my $xpath = $commander->getAclEntry("user", "project: $pluginName", {
                projectName => $otherPluginName,
                credentialName => $cred
            });
            if ($xpath->findvalue("//code") eq "NoSuchAclEntry") {
                $batch->deleteAclEntry("user", "project: $otherPluginName", {
                    projectName => $pluginName,
                    credentialName => $cred
                });
                $batch->createAclEntry("user", "project: $pluginName", {
                    projectName => $pluginName,
                    credentialName => $cred,
                    readPrivilege => "allow",
                    modifyPrivilege => "allow",
                    executePrivilege => "allow",
                    changePermissionsPrivilege => "allow"
                });
            }

# Attach the credential to the appropriate steps
            $batch->attachCredential("\$%s]", $cred, {
                procedureName => "XXXXX",
                stepName => "XXXXXX"
            });

        }
    }
}
',
	'[/plugins/$otherPluginName', '[/plugins/$pluginName/project'
);
    
$ec->setProperty("/projects/$project/promoteAction", $prop, {expandable => 0});
$ec->setProperty("summary", "YOU NEED TO MODIFY the property promoteAction. See help page for details!");
$ec->setProperty("outcome", "warning");



$[/myProject/scripts/perlLibJSON]

















