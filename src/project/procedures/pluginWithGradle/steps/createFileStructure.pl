#############################################################################
#
# Copyright 2013-2016 Electric-Cloud Inc.
#
#############################################################################
#
chdir("$[directory]");

# Create the META-INF and pages directories


mkdir ("htdocs");   # here goes the pluginhelp.css
mkdir ("pages");    # here goes the help.xml

mkdir ("src") || die ("Cannot create src");
mkdir ("src/main") || die ("Cannot create src/main");
mkdir ("src/main/resources") || die ("Cannot create src/main/resources");

# here goes plugin.xml
mkdir ("src/main/resources/META-INF") || die ("Cannot create src/main/resources/META-INF");

# ec_setup.pl, manifest.xml, procedures/ project.xml, properties/
mkdir ("src/main/resources/project") || die ("Cannot create src/main/resources/project");

