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

# Data that drives the create step picker registration for this plugin.
my %acquireSemaphore = ( 
  label       => "EC-Admin - acquireSemaphore", 
  procedure   => "acquireSemaphore", 
  description => "Acquire a token in order to limit access to a set of procedures.", 
  category    => "Administration" 
);

my %artifactRepositorySynchronization = ( 
  label       => "EC-Admin - artifactRepositorySynchronization", 
  procedure   => "artifactRepositorySynchronization", 
  description => "Syncs the contents of 2 repositories no matter what is the backing store.
Each AV backing store  to synchronize is downloaded from the source repo on the resource and uploaded to the target repo", 
  category    => "Administration" 
);

my %artifactsCleanup = ( 
  label       => "EC-Admin - artifactsCleanup", 
  procedure   => "artifactsCleanup", 
  description => "Delete old artifacts and clean caches.", 
  category    => "Administration" 
);

my %artifactsCleanup_byQuantity = ( 
  label       => "EC-Admin - artifactsCleanup_byQuantity", 
  procedure   => "artifactsCleanup_byQuantity", 
  description => "Delete old artifacts and clean caches.", 
  category    => "Administration" 
);

my %createPluginFromProject = ( 
  label       => "EC-Admin - createPluginFromProject", 
  procedure   => "createPluginFromProject", 
  description => "Transform a project into a plugin", 
  category    => "Administration" 
);

my %deleteObjects = ( 
  label       => "EC-Admin - deleteObjects", 
  procedure   => "deleteObjects", 
  description => "A procedure to quickly delete jobs or workflows older than a specified number of days. It will NOT delete associated workspace job directories.", 
  category    => "Administration" 
);

my %deleteWorkspaceOrphans = ( 
  label       => "EC-Admin - deleteWorkspaceOrphans", 
  procedure   => "deleteWorkspaceOrphans", 
  description => "Procedure to crawl a workspace directory to find orphan jobs (directories without a matching job)", 
  category    => "Administration" 
);

my %jobCleanup_byResult = ( 
  label       => "EC-Admin - jobCleanup_byResult", 
  procedure   => "jobCleanup_byResult", 
  description => "Delete jobs and the associated workspace based on  result: keeping X goods/warning, and Y failed
Report the number of jobs, the disk space and database space that could/was be deleted.", 
  category    => "Administration" 
);

my %jobsCleanup = ( 
  label       => "EC-Admin - jobsCleanup", 
  procedure   => "jobsCleanup", 
  description => "Delete jobs older than a number of days, along with the associated workspace.", 
  category    => "Administration" 
);

my %performanceMetrics = ( 
  label       => "EC-Admin - performanceMetrics", 
  procedure   => "performanceMetrics", 
  description => "Performance diagnostics for EC server and agents.", 
  category    => "Administration" 
);

my %projectAsCode = ( 
  label       => "EC-Admin - projectAsCode", 
  procedure   => "projectAsCode", 
  description => "Transform a project into a plugin", 
  category    => "Administration" 
);

my %releaseSemaphore = ( 
  label       => "EC-Admin - releaseSemaphore", 
  procedure   => "releaseSemaphore", 
  description => "Procedure to release the token.", 
  category    => "Administration" 
);

my %saveAllObjects = ( 
  label       => "EC-Admin - saveAllObjects", 
  procedure   => "saveAllObjects", 
  description => "This procedure brings a finer granularity to a full server export. For example to retrieve an object after a wrong action or a bad code change. By default it exports projects and each procedure individually. In addition by enabling the matching checkboxes, you can also export resources, resource pools, workspaces, users and groups.", 
  category    => "Administration" 
);

my %saveProjects = ( 
  label       => "EC-Admin - saveProjects", 
  procedure   => "saveProjects", 
  description => "a framework to export projects.", 
  category    => "Administration" 
);

my %synchronizePlugins = ( 
  label       => "EC-Admin - synchronizePlugins", 
  procedure   => "synchronizePlugins", 
  description => "A procedure to synchronize plugins between the server and a resource. Plugins are uploaded first as artifacts and downloaded on the resource if it does not already exist.", 
  category    => "Administration" 
);

my %workflowCleanup = ( 
  label       => "EC-Admin - workflowCleanup", 
  procedure   => "workflowCleanup", 
  description => "Delete workflows older than a number of days.
Report the number of workflows.", 
  category    => "Administration" 
);

my %ZZZ_DEPRECATED_artifactRepositorySynchronization = ( 
  label       => "EC-Admin - ZZZ_DEPRECATED_artifactRepositorySynchronization", 
  procedure   => "ZZZ_DEPRECATED_artifactRepositorySynchronization", 
  description => "Syncs the contents of a remote repository to this repository's backingstore.
The user must specify a list of remote repositories to query and may specify a filter for a subset of Artifact Version to sync.

The procedure has been deprecated in favor of the Universal one that can accommodate a S3 backend store.", 
  category    => "Administration" 
);

@::createStepPickerSteps = (\%acquireSemaphore, \%artifactRepositorySynchronization, \%artifactsCleanup, \%artifactsCleanup_byQuantity, \%createPluginFromProject, \%deleteObjects, \%deleteWorkspaceOrphans, \%jobCleanup_byResult, \%jobsCleanup, \%performanceMetrics, \%projectAsCode, \%releaseSemaphore, \%saveAllObjects, \%saveProjects, \%synchronizePlugins, \%workflowCleanup, \%ZZZ_DEPRECATED_artifactRepositorySynchronization);
