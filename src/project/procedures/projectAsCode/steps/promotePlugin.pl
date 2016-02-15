#############################################################################
#
# Copyright 2013-2015 Electric-Cloud Inc.
#
#############################################################################
use strict;
use English;
use ElectricCommander;
$| = 1;


# Create a single instance of the Perl access to ElectricCommander
my $ec = new ElectricCommander({debug=>1});

#
# promotePlugin API does not support JSON format

my $plugin="$[/myJob/pluginName]";
my $version="$[/myJob/Version]";

printf("Promoting plugin '$plugin-$version'\n");
$ec->promotePlugin("$plugin-$version");

$ec->setProperty("summary", "<html>&#160;&#160;&#160;<a href=\"/commander/link/projectDetails/plugins/$plugin-$version\">$plugin-$version</a> promoted</html>");
$ec->setProperty("/myJob/report-urls/$plugin-$version",
    "/commander/link/projectDetails/projects/$plugin-$version");










