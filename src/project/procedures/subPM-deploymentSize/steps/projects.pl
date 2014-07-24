$[/myProject/scripts/perlHeaderJSON]

################################################################################
#
# GLobal variables
#
################################################################################
my $SMALL=10;
my $LARGE=100;
my $size;
my $nb=0;

my ($ok, $json)=InvokeCommander("SuppressLog", 'getProjects');
foreach my $node ($json->findnodes('//project')) {
    # Skip plugins
    next if ($node->{pluginName});
	my $name=$node->{projectName};
    printf("Processing %s\n", $name);
	$nb++;
}


if ($nb < $SMALL) {
	$size="SMALL";
} elsif ($nb > $LARGE) {
	$size="LARGE";
} else {
	$size="MEDIUM";
}
$ec->setProperty("summary", "$size: $nb projects");
$ec->setProperty("/myJob/PM-numberOfProjects", $nb);

$[/myProject/scripts/perlLibJSON]


