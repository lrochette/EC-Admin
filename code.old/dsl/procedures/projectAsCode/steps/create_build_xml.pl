#############################################################################
#
# Copyright 2014-2015 Electric-Cloud Inc.
#
#############################################################################
$[/myProject/scripts/perlHeaderJSON]

#############################################################################
#
# Parameters
#
#############################################################################
my $project="$[Project]";
my $SDKDir="$[SDKpath]";

my $version="$[/myJob/Version]";
my $pluginName="$[/myJob/pluginName]";
my $javaName="$[/myJob/javaName]";


my $file="$[directory]/build.xml";
unless (open FILE, '>'.$file) {
        printf("File: %s\n", $file);
	die "\nUnable to create $[directory]/build.xml\n";
}
printf(FILE 
'<project name="%s" default="package" basedir=".">
  <description>
    Build the %s plugin
  </description>

  <!-- Plugin-specific properties -->
  <property name="pluginKey" value="%s" />
  <property name="pluginVersion" value="%s" />

  ',
$pluginName, $pluginName,  $pluginName, $version);  

my $configure=getP("/projects/$[Project]/configureCredentials");

if ($configure != undef) {
	printf(FILE
'
  <!-- Java code specific properties -->
  <property name="gwtModules" value="ecplugins.%s.ConfigurationManagement" />
',
	$javaName);

	printf(FILE 
'  <path id="extras">
    <pathelement location="$[SDKpath]/lib/commander-client.jar"/>
');
	my @jars=("ec_internal.jar", "gin-2.1.1.jar", 
    		  "gwtp-all-0.8-PATCH5.jar", "javax.inject.jar", 
              "guice-assistedinject.jar", "guice.jar",
              "annotations.jar");

	# check that we are running version 5.x or later
	my ($success, $xPath) = InvokeCommander("SuppressLog", "getVersions");
	my $version=$xPath->{responses}->[0]->{serverVersion}->{version};
	printf("%s\n",$version);
    my $libDir="";
	if (compareVersion($version, "5.0") < 0) {
    	$libDir="lib";
    } else {
    	$libDir="lib5"
    }          
	foreach $file (@jars) {
		printf(FILE '    <pathelement location="%s/$[/plugins/EC-Admin/projectName]/%s/%s"/>
', $ENV{COMMANDER_PLUGINS}, $libDir, $file);
    }

	printf(FILE '
  </path>
  <property name="gwt.path.extras" value="extras" />'
	);
}

#
# include extra files
my $extraFiles = getP("/projects/$[Project]/filesToCopy");
if ($extraFiles) {
	printf(FILE
'<property name="filesToCopy.extras" value="%s" />
', $extraFiles);
}


printf(FILE 
'
  <import file="$[SDKpath]/build/buildTargets.xml" />
');




printf(FILE 
'</project>
'
);

close(FILE);

$[/myProject/scripts/perlLibJSON]

