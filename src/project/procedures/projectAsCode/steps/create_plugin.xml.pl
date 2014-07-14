$[/myProject/scripts/perlHeaderJSON]

my $project="$[Project]";
my $description="$[Description]";
my $author="$[Author]";
my $email='$[Email]';
my $category="$[Category]";

my $pluginName="$[/myJob/pluginName]";
my $version="$[/myJob/Version]";

if ($author eq "") {
   $author="Electric Cloud";
}

if ($email eq "") {
   $email="plugins\@electric-cloud.com";
}

if ($description eq "") {
  $description=getP("/projects/$project/description");
}

my $file="$[directory]/META-INF/plugin.xml";
unless (open FILE, '>'.$file) {
        printf("File: %s\n", $file);
	die "\nUnable to create $[directory]/META-INF/plugin.xml\n";
}

printf(FILE '<?xml version="1.0" encoding="UTF-8"?>');
printf(FILE "\n<plugin>\n");
printf(FILE "  <key>%s</key>\n", $pluginName);
printf(FILE "  <version>%s</version>\n", $version);
printf(FILE "  <label>%s</label>\n", $pluginName);
printf(FILE "  <description>%s</description>\n", $description);

#
# Create the help entry only if it exists
my $help=getP("/projects/$project/help");
if ($help ne "") {
  printf(FILE "  <help>help.xml</help>\n");
}
printf(FILE "  <author>%s</author>\n", $author);
printf(FILE "  <authorUrl>mailto:%s</authorUrl>\n", $email);
printf(FILE "\n");

printf(FILE "  <commander-version min=\"4.1\"/>\n");
printf(FILE "\n");
    
printf(FILE "    <!-- Specify a category for this plugin; this is used in filtered lists in the Plugin Manager.
         Typically, it is set to System or Step.
     -->
");
printf(FILE "  <category>%s</category>\n", $category);
printf(FILE " 	  <depends>EC-Core</depends>\n</plugin>\n");

close FILE;


$[/myProject/scripts/perlLibJSON]
