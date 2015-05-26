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
	foreach $file (@jars) {
		printf(FILE '    <pathelement location="%s/$[/myProject/projectName]/lib/%s"/>
', $ENV{COMMANDER_PLUGINS}, $file);
    }

	printf(FILE '
  </path>
  <property name="gwt.path.extras" value="extras" />'
	);
  }
  
printf(FILE 
'
  <import file="$[SDKpath]/build/buildTargets.xml" />
</project>'
);

close(FILE);

$[/myProject/scripts/perlLibJSON]

