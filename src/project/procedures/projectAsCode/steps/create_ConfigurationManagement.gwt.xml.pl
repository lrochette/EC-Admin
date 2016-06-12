$[/myProject/scripts/perlHeaderJSON]
use File::Path;

#list of tiles to create
my @files=("ConfigurationManagement.gwt.xml");

my $configure=getP("/projects/$[Project]/configureCredentials");
my $version = "$[/myJob/version]";
my $plugin  = "$[/myJob/pluginName]";
my $javaName= "$[/myJob/javaName]";

if ($configure == undef) {
	printf("configureCredentials property does not exist\n");
    $ec->setProperty("summary", "skipping: no ConfigurationManagement.gwt.xml file to create");
	exit(0);
}

mkpath("src/ecplugins/$javaName/");
foreach my $file (@files) {
	printf("Processing $file\n");
    
	my $FILE;
  	open($FILE, "> src/ecplugins/$javaName/$file") || die("Cannot create $file");

	print $FILE getP("/myProject/pac_configurations/resources/$file");
    close($FILE);
} 

$[/myProject/scripts/perlLibJSON]


