#############################################################################
#
# Copyright 2014 Electric-Cloud Inc.
#
#############################################################################

#############################################################################
#
# Parameters
#
#############################################################################
my $project="$[Project]";
my $SDKDir="$[SDKpath]";

my $version="$[/myJob/Version]";
my $pluginName="$[/myJob/pluginName]";



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

  <path id="extras">
    <!-- Add extra jars that need to be in the classpath for building the 
         plugin here. For example:

         <pathelement location="lib/smartgwt.jar"/>

         will grab the smartgwt jar from the lib directory of the plugin.

         Note that you must also add the jar to the "Referenced Libraries" 
         section of your plugin project for Eclipse to recognize the classes in
         the jar.

         Typically, you must also add an <inherits> element to the .gwt.xml 
         file for a component that uses classes from the third-party package.
    -->
  </path>
  <property name="gwt.path.extras" value="extras" />

  <import file="$[SDKpath]/build/buildTargets.xml" />
</project>',

$pluginName, $pluginName, $pluginName, $version);

close(FILE)

