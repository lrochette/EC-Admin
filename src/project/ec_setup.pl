# promote/demote action
if ( $promoteAction eq 'promote' ) {
	my $query=$commander->newBatch();
	my $cfg = $query->getProperty("/server/EC-Admin/licenseLogger/config");
	local $self->{abortOnError} = 0;
	$query->submit();

	# If the PS does not already exist, create it
	if ($query->findvalue($cfg, "code") eq "NoSuchProperty") {
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/emailTo", "admin" );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/emailConfig", "default" );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/cleanpOldJobs", 1 );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/resource", "local" );
		$batch->setProperty( "/server/EC-Admin/licenseLogger/config/workspace", "default" );
	}

    # Give project principal "Electrirc Cloud" write access to our project
    my $projPrincipal = "project: Electric Cloud";
    my $ecAdminProj   = '$'.'[/plugins/EC-Admin/project/projectName]';

    # Give project Electric Cloud permission on ec_reportData
    $cfg = $commander->getProperty("ec_reportData", {projectName => $ecAdminProj});
    my $psId= $cfg->findvalue("//propertySheetId");
    printf("XXX DEBUG: $psId\n");
    printf("XXX DEBUG: $ecAdminProj\n");

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
}


# Data that drives the create step picker registration for this plugin.
my %acquireSemaphore = ( 
  label       => "EC-Admin - acquireSemaphore", 
  procedure   => "acquireSemaphore", 
  description => "Acquire a token in order to limit access to a set of procedures.", 
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

@::createStepPickerSteps = (\%acquireSemaphore, \%artifactsCleanup, \%artifactsCleanup_byQuantity, \%createPluginFromProject, \%deleteObjects, \%deleteWorkspaceOrphans, \%jobCleanup_byResult, \%jobsCleanup, \%performanceMetrics, \%projectAsCode, \%releaseSemaphore, \%saveAllObjects, \%saveProjects, \%synchronizePlugins, \%workflowCleanup);

