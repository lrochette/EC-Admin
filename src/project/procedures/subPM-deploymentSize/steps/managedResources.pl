$[/myProject/scripts/perlHeaderJSON]

################################################################################
#
# GLobal variables
#
################################################################################
my $SMALL=100;
my $LARGE=1000;

my ($ok, $json)=InvokeCommander("SuppressLog", 'getResources');
my $nbResources=scalar ($json->findnodes('//resource'));

my $size;
if ($nbResources < $SMALL) {
	$size="SMALL";
} elsif ($nbResources > $LARGE) {
	$size="LARGE";
} else {
	$size="MEDIUM";
}
$ec->setProperty("summary", "$size: $nbResources resources");
$ec->setProperty("/myJob/PM-numberOfResources", $nbResources);

$[/myProject/scripts/perlLibJSON]

