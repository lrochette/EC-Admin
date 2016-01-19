$[/myProject/scripts/perlHeader]

#
# installPlugin does not support JSON format

my $plugin="$[/myJob/pluginName]";
my $version="$[/myJob/Version]";



printf("Installing plugin '$plugin-$version'\n");
$ec->installPlugin("./$plugin.jar");
$ec->setProperty("summary", "<html>&#160;&#160;&#160;<a href=\"/commander/link/projectDetails/plugins/$plugin-$version\">$plugin-$version</a> installed</html>");








