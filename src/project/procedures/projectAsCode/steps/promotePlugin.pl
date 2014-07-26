$[/myProject/scripts/perlHeader]

my $plugin="$[/myJob/pluginName]";
my $version="$[/myJob/Version]";

printf("Promoting plugin '$plugin-$version'\n");
$ec->promotePlugin("$plugin-$version");
$ec->setProperty("summary", "<html>&#160;&#160;&#160;<a href=\"https://$[/server/hostName]/commander/link/projectDetails/plugins/$plugin-$version\">$plugin-$version</a> promoted</html>");

