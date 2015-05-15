$[/myProject/scripts/perlHeaderJSON]
use File::Path;

#list of tiles to create
my @files=("ConfigurationList.java", "ConfigurationManagementFactory.java",
           "CreateConfiguration.java", 
           "PluginConfigList.java", "PluginConfigListLoader.java");

my $configure=getP("/projects/$[Project]/configure");
my $version = "$[/myJob/version]";
my $plugin  = "$[/myJob/pluginName]";
my $javaName= "$[/myJob/javaName]";

if ($configure == undef) {
	printf("configure property does not exist\n");
    $ec->setProperty("summary", "skipping: no cgi-bin files to create");
	exit(0);
}

mkpath("src/ecplugins/$javaName/client");
foreach my $file (@files) {
	printf("Processing $file\n");
    
	my $FILE;
  	open($FILE, "> src/ecplugins/$javaName/client/$file") || die("Cannot create $file");

	print $FILE getP("/myProject/pac_configurations/java/$file");
    close($FILE);
} 

$[/myProject/scripts/perlLibJSON]

