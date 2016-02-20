$[/myProject/scripts/perlHeaderJSON]

#list of tiles to create
my @files=("plugin.cgi", "jobMonitor.cgi");

my $configure=getP("/projects/$[Project]/configureCredentials");
my $version="$[/myJob/version]";
my $plugin ="$[/myJob/pluginName]";

if ($configure == undef) {
	printf("configureCredentials property does not exist\n");
    $ec->setProperty("summary", "skipping: no cgi-bin files to create");
	exit(0);
}

foreach my $file (@files) {
	printf("Processing $file\n");
    
	my $FILE;
  	open($FILE, ">cgi-bin/$file") || die("Cannot create cgi-bin/$file");

	print $FILE getP("/myProject/pac_configurations/cgi-bin/$file");
    close($FILE);
} 

$[/myProject/scripts/perlLibJSON]














