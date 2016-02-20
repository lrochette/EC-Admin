$[/myProject/scripts/perlHeader]

my $plugin="$[Plugin]";
my $version="$[/myJob/Version]";

if ($plugin eq "") {
  $plugin="$[Project]";
}

printf("Promoting plugin '$plugin-$version'\n");
$ec->promotePlugin("$plugin-$version");
$ec->setProperty("summary", "$plugin-$version promoted");














