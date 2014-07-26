$[/myProject/scripts/perlHeader]

my $plugin="$[/myJob/pluginName]";
my $version="$[/myJob/Version]";



printf("Installing plugin '$plugin-$version'\n");
$ec->installPlugin("./$plugin.jar");
$ec->setProperty("summary", "<html><a href=\"https:$[/server/hostName]/commander/link/projectDetails/plugins/$plugin-$version\">$plugin-$version</a> installed</html>");

