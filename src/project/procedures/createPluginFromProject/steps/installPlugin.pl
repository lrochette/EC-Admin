$[/myProject/scripts/perlHeader]

my $plugin="$[Plugin]";
my $version="$[/myJob/Version]";

if ($plugin eq "") {
  $plugin="$[Project]";
}

printf("Installing plugin '$plugin-$version'\n");
$ec->installPlugin("./$plugin-$version.jar");
$ec->setProperty("summary", "$plugin-$version installed");










