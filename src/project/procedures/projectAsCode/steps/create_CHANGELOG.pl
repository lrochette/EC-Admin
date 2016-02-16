#############################################################################
#
# Copyright 2014 Electric-Cloud Inc.
#
#############################################################################
use strict;

#############################################################################
#
# Parameters
#
#############################################################################
my $project="$[Project]";
my $comment="$[Comment]";

my $version="$[/myJob/Version]";
my $pluginName="$[/myJob/pluginName]";

my $userFullName="$[/users/$[/myJob/launchedByUser]/fullUserName]";
my $userEmail='$[/users/$[/myJob/launchedByUser]/email]';

my $file="$[directory]/CHANGELOG";
my @changeLogContent=();

# If the CHANGELOG file exist, read it
if (-f $file) {

	unless (open FILE, '<'.$file) {
        printf("File: %s\n", $file);
		die "\nUnable to read $file\n";
	}
    @changeLogContent=<FILE>;
    printf("Content of CHANGELOG:\n");
    print @changeLogContent;
}
unshift (@changeLogContent,"$[/timestamp YYYY-MM-dd] $userFullName <$userEmail>\n" . 
						    "  * $version: $comment\n\n");

unless (open FILE, '>'.$file) {
        printf("File: %s\n", $file);
		die "\nUnable to write $file\n";
}

print(FILE @changeLogContent);
close(FILE);












