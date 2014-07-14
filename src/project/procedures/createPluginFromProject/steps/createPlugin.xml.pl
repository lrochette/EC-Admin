$[/myProject/scripts/perlHeaderJSON]

my $pluginName="$[Plugin]";
my $project="$[Project]";
my $version="$[/myJob/Version]";
my $description="$[Description]";
my $author="$[Author]";
my $email='$[Email]';
my $category="$[Category]";

if ($author eq "") {
   $author="Electric Cloud";
}
if ($email eq "") {
   $email="plugins\@electric-cloud.com";
}
if ($pluginName eq "") {
  $pluginName="$[Project]";
}
if ($description eq "") {
  $description=getP("/projects/$project/description");
}

my $file="plugin.$[/myJob/jobId]/META-INF/plugin.xml";
unless (open FILE, '>'.$file) {
        printf("File: %s\n", $file);
	die "\nUnable to create META-INF/plugin.xml\n";
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
printf(FILE "  <category>%s</category>\n</plugin>\n", $category);
close FILE;


$[/myProject/scripts/perlLibJSON]
