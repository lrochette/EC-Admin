$[/myProject/scripts/perlHeader]

my $plugin="$[/myJob/pluginName]";
my $version="$[/myJob/Version]";



printf("Installing plugin '$plugin-$version'\n");
$ec->installPlugin("./$plugin.jar");
$ec->setProperty("summary", "$plugin-$version installed");

