use Cwd;
use File::Spec;
use POSIX;
use MIME::Base64;
use File::Temp qw(tempfile tempdir);
use Archive::Zip;
use Digest::MD5 qw(md5_hex);

my $dir = getcwd;
my $logfile ="";
my $pluginDir;


if ( defined $ENV{QUERY_STRING} ) {    # Promotion through UI
    $pluginDir = $ENV{COMMANDER_PLUGINS} . "/$pluginName";
}
else {
    my $commanderPluginDir = $commander->getProperty('/server/settings/pluginsDirectory')->findvalue('//value');
    # We are not checking for the directory, because we can run this script on a different machine
    $pluginDir = "$commanderPluginDir/$pluginName";
}

$logfile .= "Plugin directory is $pluginDir";

$commander->setProperty("/plugins/$pluginName/project/pluginDir", {value=>$pluginDir});
$logfile .= "Plugin Name: $pluginName\n";
$logfile .= "Current directory: $dir\n";

# Evaluate promote.groovy or demote.groovy based on whether plugin is being promoted or demoted ($promoteAction)
local $/ = undef;


my $demoteDsl = q{
# demote.groovy placeholder
};

my $promoteDsl = q{
# promote.groovy placeholder
};


my $dsl;
if ($promoteAction eq 'promote') {
  $dsl = $promoteDsl;
}
else {
  $dsl = $demoteDsl;
}

my $dslReponse = $commander->evalDsl(
    $dsl, {
        parameters => qq(
                     {
                       "pluginName":"$pluginName",
                       "upgradeAction":"$upgradeAction",
                       "otherPluginName":"$otherPluginName"
                     }
              ),
        debug             => 'false',
        serverLibraryPath => "$pluginDir/dsl"
    },
);


$logfile .= $dslReponse->findnodes_as_string("/");
my $errorMessage = $commander->getError();

# Create output property for plugin setup debug logs
my $nowString = localtime;
$commander->setProperty( "/plugins/$pluginName/project/logs/$nowString", { value => $logfile } );

die $errorMessage unless !$errorMessage;



# I suppose, this should go in the promote.groovy or demote.groovy
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
    my $ecAdminProj = $pluginName;

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
    $projPrincipal="project: $pluginName";
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
    my $projPrincipal="project: $pluginName";
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
