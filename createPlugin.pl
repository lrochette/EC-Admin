#!/usr/bin/env perl
# Build, upload and promote PluginLite
use Getopt::Long;
use XML::Simple qw(:strict);
use Data::Dumper;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Archive::Zip::Tree;
use strict;
use ElectricCommander ();
$| = 1;
my $ec = new ElectricCommander->new();

my $pluginVersion = "3.1.0";

my $pluginKey = "EC-Admin2";
my $description = "A set of administrative tasks to help manage your server.";
GetOptions ("version=s" => \$pluginVersion,
			"pluginKey=s"   => \$pluginKey,
			"description=s"  => \$description
			) or die (qq(
Error in command line arguments

	createPlugin.pl
		[--version <version>]
		[--pluginKey <version>]
		[--description <version>]

		)
);

# Read buildCounter
my $buildCounter;
{
  local $/ = undef;
  open FILE, "buildCounter" or die "Couldn't open file: $!";
  $buildCounter = <FILE>;
  close FILE;

 $buildCounter++;
 $pluginVersion .= ".$buildCounter";
 print "[INFO] - Incrementing build number to $buildCounter...\n";

 open FILE, "> buildCounter" or die "Couldn't open file: $!";
 print FILE $buildCounter;
 close FILE;
}
my $pluginName = "${pluginKey}-${pluginVersion}";

my $xs = XML::Simple->new(
	ForceArray => 1,
	KeyAttr    => { },
	KeepRoot   => 1,
);

# Update project.xml with
#		ec_setup.pl,
#		plugin Name
#		plugin version
print "[INFO] - Processing 'META-INF/project.xml' file...\n";
my $xmlFile = "META-INF/project.xml";
my $file = "ec_setup.pl";
my $value;
{
  local $/ = undef;
  open FILE, $file or die "Couldn't open file: $!";
  binmode FILE;
  $value = <FILE>;
  close FILE;
}

my $ref  = $xs->XMLin($xmlFile);
$ref->{exportedData}[0]->{project}[0]->{propertySheet}[0]->{property}[0]->{value}[0] = $value;

#  change name and version
$ref->{exportedData}[0]->{exportPath}[0] = "/projects/$pluginName";
$ref->{exportedData}[0]->{project}[0]->{projectName}[0] = "$pluginName";
open(my $fh, '>', $xmlFile) or die "Could not open file '$xmlFile' $!";
print $fh $xs->XMLout($ref);
close $fh;

# Update plugin.xml with key, version, label, description
print "[INFO] - Processing 'META-INF/plugin.xml' file...\n";
$xmlFile = "META-INF/plugin.xml";
$ref  = $xs->XMLin($xmlFile);
$ref->{plugin}[0]->{key}[0] = $pluginKey;
$ref->{plugin}[0]->{version}[0] = $pluginVersion;
$ref->{plugin}[0]->{label}[0] = $pluginKey;
$ref->{plugin}[0]->{description}[0] = $description;
open(my $fh, '>', $xmlFile) or die "Could not open file '$xmlFile' $!";
print $fh $xs->XMLout($ref);
close $fh;

# Create plugin jar file
print "[INFO] - Creating plugin jar file, ${pluginKey}.jar\n";
my $zip = Archive::Zip->new();
my $directory = '.';
opendir (DIR, $directory) or die $!;
while (my $file = readdir(DIR)) {
	$zip->addTree( $file, $file ) unless (
		$file eq "systemtest" or
		$file =~ m/EC-Admin/ or
		$file =~ "createPlugin.pl" or
		$file =~ "buildCounter" or
		$file eq ".gitignore" or
		$file eq "src" or
		$file eq "README.md" or
		$file eq "ec_setup.pl" or
		$file eq "CHANGELOG" or
		$file eq ".git" or
		$file eq "." or
		$file eq ".."
		);
}
# Save the Zip file
unless ( $zip->writeToFileNamed("${pluginKey}.jar") == AZ_OK ) {
	die 'write error';
}

# Uninstall old plugin
print "[INFO] - Uninstalling old plugin...\n";
$ec->uninstallPlugin($pluginName) || print "No old plugin\n";

# Install plugin
print "[INFO] - Installing plugin...\n";
$ec->installPlugin("${pluginKey}.jar");

# Promote plugin
print "[INFO] - Promoting plugin...\n";
$ec->promotePlugin($pluginName);
