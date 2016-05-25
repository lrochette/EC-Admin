#############################################################################
#
# Copyright 2014-2016 Electric-Cloud Inc.
#
#############################################################################
$[/myProject/scripts/perlHeaderJSON]

#############################################################################
#
# Parameters
#
#############################################################################
my $project="$[Project]";
my $description="$[description]";
my $version="$[/myJob/Version]";
my $pluginName="$[/myJob/pluginName]";
my $javaName="$[/myJob/javaName]";


my $file="$[directory]/build.gradle";
unless (open FILE, '>'.$file) {
        printf("File: %s\n", $file);
	die "\nUnable to create $[directory]/build.gradle\n";
}
printf(FILE
'// -*- Groovy -*-
// build.gradle
//
// Gradle build script for %s  plugin.
//
// Copyright (c) 2016 Electric Cloud, Inc.
// All rights reserved

buildscript {
        repositories {
                maven { url \'http://dl.bintray.com/ecpluginsdev/maven\' }
                jcenter()
        }
        dependencies {
                classpath group: \'com.electriccloud.plugins\', name: \'flow-gradle-plugin\', version: \'+\'
        }
}

group = "com.electriccloud"
description = "%s"
version = "%s"

apply plugin: \'flow-gradle-plugin\'

license {
    header = file (\'shortHeader.txt\')
    exclude "**/project.xml"

}

task wrapper(type: Wrapper) { gradleVersion = \'2.12\' }

',
$pluginName, $description,  $version);


close(FILE);

