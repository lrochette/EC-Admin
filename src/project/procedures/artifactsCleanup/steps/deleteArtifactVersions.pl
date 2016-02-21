#############################################################################
#
#  deleteArtifactVersions -- Script to delete artifacts and caches
#  Copyright 2013 Electric-Cloud Inc.
#
#############################################################################

use DateTime;
$[/myProject/scripts/perlHeader]
$[/myProject/scripts/perlLib]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $artifactProperty = "$[artifactProperty]";
my $timeLimit = $[olderThan];
my $executeDeletion= "$[executeDeletion]";

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

printf("%s artifacts older than $timeLimit days (%s).\n", 
    $executeDeletion eq "true"?"Deleting":"Reporting", 
    calculateDate($timeLimit));

my ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", 
										"artifact", {sort => [ {propertyName => "groupId",
                                                    order => "ascending"} ]});
# Loop over artifacts
my $nodeset = $xPath->find('//artifact');
foreach my $node ($nodeset->get_nodelist) {
	my $artifactName=$xPath->findvalue('artifactName', $node);
	printf("%s\n", $artifactName);

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
	my ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", 
											"artifactVersion",
					 						{'filter' => \@filterList});
	my $versionset = $xPath->findnodes('//artifactVersion');
	foreach my $version ($versionset->get_nodelist) {
		#print $version->findnodes_as_string("/") . "\n";
		my $versionNumber=$version->findvalue('./artifactVersionName', $node);
		if ($executeDeletion eq "true") {
			 my ($success, $xPath) = InvokeCommander("SuppressLog", "deleteArtifactVersion", 
                      $versionNumber);
			printf("\tDeleting %s\n", $versionNumber);
		} else {
			printf("\t%s\n", $versionNumber);
		}

	}	
	printf("\n");
}
#############################################################################
#
#  Calculate the size of the workspace directory
#
#############################################################################
sub getDirSize {
  my $dir  = shift;
  my $size = 0;

  opendir(D,"$dir") || return 0;
  foreach my $dirContent (grep(!/^\.\.?/,readdir(D))) {
     my $st=stat("$dir/$dirContent");
     if (S_ISREG($st->mode)) {
       $size += $st->size;
     } elsif (S_ISDIR($st->mode)) {
       $size += getDirSize("$dir/$dirContent");
     }
  }
  closedir(D);
  return $size;
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


#############################################################################
#
#  Return human readable size
#
#############################################################################
sub humanSize {
  my $size = shift();

  if ($size > 1099511627776) {    #   TB: 1024 GB
      return sprintf("%.2f TB", $size / 1099511627776);
  }
  if ($size > 1073741824) {       #   GB: 1024 MB
      return sprintf("%.2f GB", $size / 1073741824);
  }
  if ($size > 1048576) {          #   MB: 1024 KB
      return sprintf("%.2f MB", $size / 1048576);
  }
  elsif ($size > 1024) {          #   KiB: 1024 B
      return sprintf("%.2f KB", $size / 1024);
  }
                                  #   bytes
  return "$size byte" . ($size <= 1 ? "" : "s");
}


















