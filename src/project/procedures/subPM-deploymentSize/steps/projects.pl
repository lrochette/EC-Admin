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

# create filterList
my @filterList;
# only non plugin
push (@filterList, {"propertyName" => "pluginName",
                    "operator" => "equals",
                    "operand1" => ""});

my ($ok, $json)=InvokeCommander("SuppressLog", 'countObjects', 'project', {filter=>\@filterList});
$nb=$json->{responses}->[0]->{count};


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






