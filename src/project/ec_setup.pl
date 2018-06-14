# promote/demote action
if ( $promoteAction eq 'promote' ) {
    local $self->{abortOnError} = 0;

    # If the licenseLogger config PS does not already exist, create it
    my $cfg = $commander->getProperty("/server/EC-Admin/licenseLogger/config");
	if ($cfg->findvalue("//code") eq "NoSuchProperty") {
        # we need the top PS later for the ACLs
        $commander->createProperty("/server/EC-Admin", {propertyType => 'sheet'});
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/emailTo", "admin",{description=>'comma separated list of userid or email'} );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/emailConfig", "default",{description=>'The name of your email configuration'} );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/cleanpOldJobs", 1 );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/resource", "local" );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/workspace", "default" );
	}

    # If the cleanup config PS does not already exist, create it
    $cfg = $commander->getProperty("/server/EC-Admin/cleanup/config");
    if ($cfg->findvalue("//code") eq "NoSuchProperty") {
        $batch->setProperty( "/server/EC-Admin/cleanup/config/timeout", 600);
    }

    # Give project principal "Electric Cloud" write access to our project
    my $projPrincipal = "project: Electric Cloud";
    my $ecAdminProj = '@PLUGIN_NAME@';

    # Give project Electric Cloud permission on ec_reportData
    $cfg = $commander->getProperty("ec_reportData", {projectName => $ecAdminProj});
    my $psId= $cfg->findvalue("//propertySheetId");

    my $xpath = $commander->getAclEntry("user", $projPrincipal,
            {
                projectName => $ecAdminProj,
                propertySheetId => $psId
            });
    if ($xpath->findvalue('//code') eq 'NoSuchAclEntry') {
        $batch->createAclEntry("user", "project: Electric Cloud",
             {
                projectName => $ecAdminProj,
                propertySheetId => $psId,
                "readPrivilege"=>"allow",
                "modifyPrivilege"=>"allow",
             });
    }

    #
    # Give Everyone permission on /server/counters/EC-Admin
    $cfg = $commander->getProperty("/server/counters/EC-Admin/jobCounter");
    if ($cfg->findvalue("//code") eq "NoSuchProperty") {
        $batch->setProperty( "/server/counters/EC-Admin/jobCounter", 0);
    }

    $cfg=$commander->getProperty("/server/counters/EC-Admin");
    $psId= $cfg->findvalue("//propertySheetId");

    $xpath = $commander->getAclEntry("group", "Everyone", {propertySheetId => $psId});
    if ($xpath->findvalue('//code') eq 'NoSuchAclEntry') {
        $batch->createAclEntry("group", "Everyone",
             {
                propertySheetId => $psId,
                "readPrivilege" =>"allow",
                "modifyPrivilege" =>"allow",
             });
    }


    # Give plugin permission on /server/EC-Admin
    $projPrincipal='project: @PLUGIN_NAME@';
    $cfg = $commander->getProperty("/server/EC-Admin");
    $psId= $cfg->findvalue("//propertySheetId");

    $xpath = $commander->getAclEntry("user", $projPrincipal,
            {
                propertySheetId => $psId
            });
    if ($xpath->findvalue('//code') eq 'NoSuchAclEntry') {
        $batch->createAclEntry("user", "$projPrincipal",
             {
                propertySheetId => $psId,
                "readPrivilege" =>"allow",
                "modifyPrivilege" =>"allow",
                "changePermissionsPrivilege" => "allow",
             });
    }
   # Remove previous plugin permission on /server/EC-Admin
   if ($otherPluginName ne "") {
        my $otherProjPrincipal="project: $otherPluginName";
        # $psId is the same than above
        $xpath = $commander->getAclEntry("user", $otherProjPrincipal,
                {
                    propertySheetId => $psId
                });
        if ($xpath->findvalue('//principalName') eq $otherProjPrincipal) {
            $batch->deleteAclEntry("user", "$otherProjPrincipal",
                 {
                    propertySheetId => $psId,
                 });
        }
    }

} elsif ( $promoteAction eq 'demote' ) {
    # Remove plugin permission on /server/EC-Admin
    my $projPrincipal='project: @PLUGIN_NAME@';
    my $cfg = $commander->getProperty("/server/EC-Admin");
    my $psId= $cfg->findvalue("//propertySheetId");

    my $xpath = $commander->getAclEntry("user", $projPrincipal,
            {
                propertySheetId => $psId
            });
    if ($xpath->findvalue('//principalName') eq $projPrincipal) {
        $batch->deleteAclEntry("user", "$projPrincipal",
             {
                propertySheetId => $psId,
             });
    }
}
