$[/myProject/scripts/perlHeader]

#
# promotePlugin PAI does not support JSON format

my $plugin="$[/myJob/pluginName]";
my $version="$[/myJob/Version]";

printf("Promoting plugin '$plugin-$version'\n");
$ec->promotePlugin("$plugin-$version");

$ec->setProperty("summary", "<html>&#160;&#160;&#160;<a href=\"/commander/link/projectDetails/plugins/$plugin-$version\">$plugin-$version</a> promoted</html>");
$ec->setProperty("/myJob/report-urls/$plugin-$version",
    "/commander/link/projectDetails/projects/$plugin-$version");

