$[/myProject/scripts/perlHeaderJSON]

################################################################################
#
# GLobal variables
#
################################################################################
my $SMALL=50;
my $LARGE=1000;
my $nbAgents;
my $size;
my %hAg;

my ($ok, $json)=InvokeCommander("SuppressLog", 'getResources');

#
# Loop over resources to extract unique hostnames
#
foreach my $node ($json->findnodes('//resource')){
	printf("Processing %s\n", $node->{hostName});
    $hAg{lc($node->{hostName})}=1;
}

$nbAgents=scalar(keys(%hAg));
if ($nbAgents < $SMALL) {
	$size="SMALL";
} elsif ($nbAgents > $LARGE) {
	$size="LARGE";
} else {
	$size="MEDIUM";
}
$ec->setProperty("summary", "$size: $nbAgents agents");
$ec->setProperty("/myJob/PM-numberOfAgents", $nbAgents);

$[/myProject/scripts/perlLibJSON]






















