$[/myProject/scripts/perlHeaderJSON]

############################################################################
#
# parameters
#
############################################################################
my $pattern="";

############################################################################
#
# Global variables
#
############################################################################
$DEBUG=0;
my ($success, $xPath);
my $MAX=5000;
my $nbCollidingProps=0;

#
# List of Deploy objectList
#  Equal sign is to ensure only the full word is found in the grep
my @objectList= qq(=applications= =clusters= =components= =containers=
    =deployers= =environments= =reservations= =environmentTemplates=
    =flowRuntimes= =flows= =pipelines= =processes= =releases=
    =resourceTemplates= =rollingDeployConfigs= =services=
    =stages=);

# create filterList
my @filterList;
if ($pattern ne "") {
  push (@filterList, {"propertyName" => "projectName",
                      "operator" => "like",
                      "operand1" => $pattern
                    }
  );
}
push (@filterList, {"propertyName" => "pluginName",
                      "operator" => "isNull"});

# Get list of Project
my ($success, $xPath) = InvokeCommander("SuppressLog", "findObjects", "project",
                                      {maxIds => $MAX,
                                       numObjects => $MAX,
                                       filter => \@filterList });

foreach my $node ($xPath->findnodes('//project')) {
  my $pName=$node->{'projectName'};
  printf("Processing Project: %s\n", $pName) if ($DEBUG);

  #
  # process top level properties
  #
  my ($suc1, $res1) = InvokeCommander("SuppressLog", "getProperties",
    {
      projectName => $pName,
      recurse => 0,
      expand => 0
    });
  foreach my $prop ($res1->findnodes('//property')) {
    my $propName=$prop->{'propertyName'};
    printf(" Property: %s\n", $propName) if ($DEBUG);

    if (grep (/=$propName=/i, @objectList )) {
      $nbCollidingProps++;
      printf("*** project property will collide with Deploy object: %s::%s\n", $pName, $propName);
    }

  }    # properties loop
}    # project loop

printf("\nSummary:\n");
printf(" Number of properties: $nbCollidingProps\n");

$ec->setProperty("/myJob/nbCollidingProps", $nbCollidingProps);
$ec->setProperty("summary", "Props: $nbCollidingProps");

$[/myProject/scripts/perlLibJSON]


