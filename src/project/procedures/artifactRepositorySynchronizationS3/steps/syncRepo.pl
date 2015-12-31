#############################################################################
#
#  SyncRepo -- Script to synchronize artifact repositories
#  Copyright 2005-2014 Electric-Cloud Inc.
#
#############################################################################

use ElectricCommander::ArtifactManagement::ArtifactVersion;

$[/plugins[EC-Admin]project/scripts/perlHeader]


#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $sourceRepo = "$[sourceRepository]";
my $targetRepo = "$[targetRepository]";
@gavPatterns   = split(",", "$[artifactVersionPattern]");
my $pageSize=$[batchSize];

# ------------------------------------------------------------------------
# parsePatterns
#
#      Parse the gav-patterns array and return an array of findObjects
#      filters.
#
# Arguments:
#      None.
# ------------------------------------------------------------------------
sub parsePatterns
{
    my @filters = ();
    foreach my $pat (@gavPatterns) {
        # Each pattern is of the form g:a:v, where any component may be
        # omitted or be *.
        # "", "*", "*:", etc. are all legal. Empty is interpreted as *.
        # We do parse version ranges and treat them specially.

        my %patComponents = ();
        ($patComponents{groupId},
         $patComponents{artifactKey},
         $patComponents{version}) = split(":", $pat);

        my @gavFilter = ();

        foreach my $idx (keys(%patComponents)) {
            my $patComponent = $patComponents{$idx};
            if (!defined($patComponent) || $patComponent eq "*" ||
                    $patComponent eq "") {
                # No pattern for this component of gav, or it's "*";
                # nothing to filter.
                next;
            }

            if ($patComponent =~ /\*/) {
                die("Invalid pattern: '$pat': $idx must be specified " .
                        "as either a literal, *, or possibly version range.\n");
            }

            # It's a literal! Or if this is the version piece,
            # it could be a version range.
            if ($idx eq "version" && $patComponent =~ /^[\[\(]/) {
                my ($lowerBnd, $lowerInc, $upperBnd, $upperInc) =
                    parseVersionRange($patComponent);
                if (defined($lowerBnd) && $lowerBnd ne "") {
                    push(@gavFilter,
                         createFilter($idx, $lowerInc ?
                                          "greaterOrEqual" : "greaterThan",
                                      $lowerBnd),
                     );
                }
                if (defined($upperBnd) && $upperBnd ne "") {
                    push(@gavFilter,
                         createFilter($idx, $upperInc ?
                                          "lessOrEqual" : "lessThan",
                                      $upperBnd),
                     );
                }
            } else {
                push(@gavFilter, createFilter($idx, "equals",
                                              $patComponent));
            }
        }

        if (@gavFilter > 0) {
            push(@filters, {
                operator => "and",
                filter => \@gavFilter
            });
        }
    }

    return @filters;
}


#############################################################################
#
#  Main
#
#############################################################################


# Find artifact versions in the server that match the given criteria
my @filters = ({propertyName => "artifactVersionState",
                    operator => "notEqual",
                    operand1 => "publishing"});
                    
my @gavFilters = parsePatterns();
if (@gavFilters > 0) {
        push(@filters, {operator => "or",
                        filter => \@gavFilters});
}

my $xpath = $ec->findObjects("artifactVersion", {
        maxIds => 0,
        numObjects => $pageSize,
        filter => \@filters,
        sort => [{propertyName => "groupId", order => "ascending"},
                 {propertyName => "artifactKey", order => "ascending"},
                 {propertyName => "version", order => "ascending"}
             ]
});

# Collect objectIds for subsequent requests
my @objects = $xpath->findnodes("/responses/response/objectId");
my $count = scalar(@objects);
printf("$count objects returned.\n");

# Walk through returned artifact versions, checking if we have each in
# the backingstore. If not, download from one of the repositories.

# The starting index for the next getObjects call
my $start = 0;

# Loop through one page at a time
my $loopCounter=0;
do {
  $loopCounter++;
  printf("\nBatch $loopCounter\n");
  foreach my $node ($xpath->findnodes("/responses/response/object/artifactVersion")) {
    my $artifactVersion = ElectricCommander::ArtifactManagement::ArtifactVersion->new($node);
    my $repositoryDir = sprintf("%s/%s/%s/%s",
        $backingstorePath,
        $artifactVersion->groupId,
        $artifactVersion->artifactKey,
        $artifactVersion->version);
    # Check if AV already exist on the target repo    
    if (! -d $repositoryDir) {
      # Download.
        if (!$didLoadRepos) {
        $::gAM->loadRepositoryInfo();
        my @verifiedRepoList =
        $::gAM->processRepositoryNames(\@repoNames);
        @repoUrlList = map {($httpProxy ? "https://$_" : $::gAM->{repoUrl}->{$_}) } @verifiedRepoList;
        $didLoadRepos = 1;
        }
        downloadArtifactVersion(\@repoUrlList,
        $artifactVersion->groupId,
        $artifactVersion->artifactKey,
        $artifactVersion->version,
        $repositoryDir);
        } else {
        printf("Found %s:%s:%s in repository\n",
        $artifactVersion->groupId,
        $artifactVersion->artifactKey,
        $artifactVersion->version);
        }
      }

      # Prepare next loop
      $count -= $pageSize;
      if ($count > 0) {
          # Create an array of object IDs for the next getObjects call
          $start += $pageSize;
          my @objectIds = ();
          for (my $index = $start; $index < $start + $pageSize; $index++) {
              if (exists($objects[$index])) {
                  push(@objectIds, $objects[$index]->findvalue("text()")->value());
              } else {
                  last;
              }
          }

          # Next page getObjects request
          $xpath = $::gCommander->getObjects({objectId => \@objectIds});
      }

} while ($count > 0);
