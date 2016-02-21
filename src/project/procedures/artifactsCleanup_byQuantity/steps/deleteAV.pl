#############################################################################
#
#  deleteArtifactVersions -- Script to delete artifacts and caches
#  Copyright 2013-2014 Electric-Cloud Inc.
#
#############################################################################

use DateTime;
$[/myProject/scripts/perlHeaderJSON]


####################################################a#########################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $artifactProperty = "$[artifactProperty]";
my $executeDeletion  = "$[executeDeletion]";
my $nbToPreserve     =  $[nbToPreserve];
my $timeLimit       =  $[olderThan];

#############################################################################
#
#  Global Variables
#
#############################################################################

#############################################################################
#
#  Main
#
#############################################################################

printf("%s artifact versions older than $timeLimit days (%s).\n", 
    $executeDeletion eq "true"?"Deleting":"Reporting", 
    calculateDate($timeLimit));
printf("  Preserving %d artifact versions\n", $nbToPreserve);

#
# Loop over each Artifacts
#
my ($ok, $res) = InvokeCommander("SuppressLog", "getArtifacts");
foreach my $art ($res->findnodes('//artifact')) {
  	my $artifactName=$art->{artifactName};
	printf("Processing artifact '%s'\n", $artifactName);

	# create filterList
	my @filterList;
	push (@filterList, {"propertyName" => 'artifactName',
                    "operator" => "equals",
                    "operand1" => $artifactName});
	push (@filterList, {"propertyName" => "createTime",
 	                    "operator" => "lessThan",
 	                  	"operand1" => calculateDate($timeLimit)});
	push (@filterList, {"propertyName" => $artifactProperty,
                    "operator" => "isNull"});
	my ($ok2, $res2) = InvokeCommander("SuppressLog", "findObjects", "artifactVersion",
					 						{'filter' => \@filterList,
                       sort => [ {propertyName => "createTime",
                                  order => "descending"} ]});
  	my $count=1;
  	foreach my $av ($res2->findnodes('//artifactVersion')) {
    	my $avName=$av->{artifactVersionName};
    	printf("\t%s\n", $avName);
    	if ($count <= $nbToPreserve) {
      		printf("\t\tpreserving : %d out of %d\n", $count, $nbToPreserve);
      		$count++;
      		next;
    	} 
		if ($executeDeletion eq "true") {
			my ($success, $xPath) = InvokeCommander("SuppressLog", "deleteArtifactVersion", $avName);
			printf("\t\tDeleting\n");
		}

	}	
	printf("\n");
}


#############################################################################
#
#  Calculate the Date based on now and the number of days required by
#  the user before deleting jobs
#
#############################################################################
sub calculateDate {
    my $nbDays=shift;
    return DateTime->now()->subtract(days => $nbDays)->iso8601() . ".000Z";
}


$[/myProject/scripts/perlLibJSON]

















