$[/myProject/scripts/perlHeaderJSON]

# list of files and titles
my %files= (
  "configurations"    => {title => "%s Configuration",  panel => "list"},
  "editConfiguration" => {title => "Edit %s Configuration", panel => "edit"},
  "newConfiguration"  => {title => "New %s Configuration",  panel => "create"});

my $configure=getP("/projects/$[Project]/configureCredentials");
my $version="$[/myJob/version]";
my $plugin ="$[/myJob/pluginName]";

if ($configure == undef) {
	printf("configureCredentials property does not exist\n");
    $ec->setProperty("summary", "skipping: no configureCredentials property");
	exit(0);
}

foreach my $file (keys %files) {
	printf("Processing $file.xml\n");
    
	my $FILE;
  	open($FILE, ">pages/$file.xml") || die("Cannot create pages/$file.xml");

    my $title=$files{$file}->{title};
	my $panel=$files{$file}->{panel};
	print $FILE "<page>\n";
    print $FILE "  <componentContainer>\n";
    printf ($FILE "    <title>$title</title>\n", $plugin);
    print $FILE "    <helpLink>/pages/$plugin-$version/help</helpLink>\n";
    print $FILE "    <component plugin=\"$plugin\"\n";
    print $FILE "               version=\"$version\"\n";
    print $FILE "               ref=\"ConfigurationManagement\">\n";
    print $FILE "        <panel>$panel</panel>\n";
    print $FILE "    </component>\n";
    print $FILE "  </componentContainer>\n";
	print $FILE "</page>\n";
    
  close($FILE);
} 

$[/myProject/scripts/perlLibJSON]


