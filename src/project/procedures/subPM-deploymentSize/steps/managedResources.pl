$[/myProject/scripts/perlHeaderJSON]

################################################################################
#
# GLobal variables
#
################################################################################
my $SMALL=100;
my $LARGE=1000;

my ($ok, $json)=InvokeCommander("SuppressLog", 'countObjects', 'resource');
my $nbResources=$json->{responses}->[0]->{count};

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
















