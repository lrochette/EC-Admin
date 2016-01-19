$[/myProject/scripts/perlHeaderJSON]

my $version = getVersion();
printf("Version: $version\n");
$version =~ /^(\d+\.\d+)/;
$version =$1;

printf("Version: $version\n");

$ec->setProperty("/myJob/webVersion", $version);

$[/myProject/scripts/perlLibJSON]








