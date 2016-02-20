$[/myProject/scripts/perlHeaderJSON]

use DateTime;

################################################################################
#
# GLobal variables
#
################################################################################
my $SMALL=5000;
my $LARGE=20000;
my $size;
my $nbDays=7;		# check over the last 7 days only
my $count=0;		# total number of jobs
my $nb=1.0;
my $now="$[/timestamp yyyy-MM-dd]" . "T00:00:00.000Z";
my $weekAgo=calculateDate($nbDays);

printf("Now: $now\n");
printf("1 week: $weekAgo\n");

# create filterList
my @filterList;
# newer than
push (@filterList, {"propertyName" => "start",
                    "operator" => "greaterOrEqual",
                    "operand1" => $weekAgo});
# older than today midnight
push (@filterList, {"propertyName" => "start",
                    "operator" => "lessThan",
                    "operand1" => $now});

my ($ok, $json)=InvokeCommander("", 'countObjects', 'jobStep',
									{filter => \@filterList}
								);
$count=$json->{responses}->[0]->{count};

$nb=$count/$nbDays;

printf("Count: %d\n", $count);
printf("Average: %3.1f\n", $nb);
if ($nb < $SMALL) {
	$size="SMALL";
} elsif ($nb > $LARGE) {
	$size="LARGE";
} else {
	$size="MEDIUM";
}
$ec->setProperty("summary", sprintf("$size: %.1f jobs per day", $nb));
$ec->setProperty("/myJob/PM-numberOfJobStepsPerDay", sprintf("%.1f", $nb));

exit(0);


#############################################################################
#
#  Return the day/time at midnight X days back
#
#############################################################################
sub calculateDate {
    my $nbDays=shift;
    my $string=DateTime->now()->subtract(days => $nbDays)->iso8601();
    $string =~ s/(\d{4}-\d{1,2}-\d{1,2})T.*/$1/;
    $string .= "T00:00:00.000Z";
    return $string;
}


$[/myProject/scripts/perlLibJSON]

















