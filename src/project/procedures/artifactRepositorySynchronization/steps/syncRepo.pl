#############################################################################
#
#  SyncRepo -- Script to synchronize artifact repositories no matter the
#                 backing store.
#  Copyright 2005-2016 Electric-Cloud Inc.
#
#############################################################################

use ElectricCommander::ArtifactManagement;
use ElectricCommander::ArtifactManagement::ArtifactVersion;
use MIME::Base64;
use HTTP::Request::Common qw(HEAD GET PUT POST);
use HTTP::Headers;
use HTTP::Cookies;
use LWP::ConnCache;
use LWP::UserAgent;
use File::Temp qw (tempdir);

$[/plugins[EC-Admin]project/scripts/perlHeader]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $sourceRepo  = "$[sourceRepository]";
my $targetRepo  = "$[targetRepository]";
my @gavPatterns = split(",", "$[artifactVersionPattern]");
my $pageSize    = $[batchSize];

#############################################################################
#
#  Global
#
#############################################################################
my $gAM=new ElectricCommander::ArtifactManagement($ec);
my $targetRepoUrl = undef;
my $sourceRepoUrl  = undef;
my $httpProxy = undef;
my $userAgent = undef;
my $error=0;    # Number of error detected
my $sync=0;     # Number of AV sync properly

# ------------------------------------------------------------------------
# downloadArtifactVersion
#
#      Download the given artifact version from one source repo (GET)
#         then write to the targetRepo (POST)
#
# Arguments:
#      groupId
#      artifactKey
#      version
# ------------------------------------------------------------------------
sub downloadArtifactVersion($$$) {
  my ($groupId, $artifactKey, $version) = @_;
  my $gav = "$groupId:$artifactKey:$version";

  my $tmpdir = tempdir(CLEANUP => 1);
  #printf("Temp file: $tmpdir\n");

  my $repoUrl = "$sourceRepoUrl/artifacts/$groupId/$artifactKey/$version";
  my $authorization = "Basic " . encode_base64("commanderSession:" . $ec->{sessionId});

  # dowload manifest file
  my $request = GET $repoUrl . "?manifest",
          "Authorization" => $authorization,
          "X-originating-server" => $ec->{server};
  my $response = $userAgent->request($request, "$tmpdir/manifest");
  if ($response->is_success) {
      # print "Successfully synced down manifest for $gav\n";
  } else {
    print "ERROR: couldn't retrieve manifest for $gav\n";
    $ec->setProperty("outcome", "error");
    $error++;
    return;
  }

  # dowload artifact file
  my $request = GET $repoUrl,
          "Authorization" => $authorization,
          "X-originating-server" => $ec->{server};
  my $response = $userAgent->request($request, "$tmpdir/artifact");
  if ($response->is_success) {
      # print "Successfully synced down artifact for $gav\n";
  } else {
    print "ERROR: couldn't retrieve artifact for $gav\n";
    $ec->setProperty("outcome", "error");
    $error++;
    return;
  }
  print "  Successfully synced down $gav\n";
  #
  # Upload file to Target Repo
  #
  my $repoUrl = "$targetRepoUrl/artifacts/$groupId/$artifactKey/$version";
  # For dynamic file upload
  my $readFunc = sub {
    read FH, my $buf, 65536;
    return $buf;
  };

  # Now let's upload the artifact to the target repo
  open FH, "$tmpdir/artifact";
  binmode FH;

  my $header=HTTP::Headers->new;
  $header->content_type('application/octet-stream');
  $header->authorization($authorization);
  my $request = HTTP::Request->new("PUT", $repoUrl, $header, $readFunc);
  $request->header("X-originating-server" => $ec->{server});

  #printf("Request: %s\n", $request->as_string());
  my $response = $userAgent->request($request);

  if ($response->is_success) {
      #print "Successfully synced up artifact for $gav\n";
  } else {
    print "ERROR: couldn't publish artifact for $gav\n";
    print $response->status_line . "\n\n";
    $ec->setProperty("outcome", "error");
    $error++;
    return;
  }
  close FH;

  # Now let's upload the manifest to the target repo
  open FH, "$tmpdir/manifest";

  my $header=HTTP::Headers->new;
  $header->content_type('application/octet-stream');
  $header->authorization($authorization);
  my $request = HTTP::Request->new("PUT", $repoUrl . "?manifest", $header, $readFunc);
  $request->header("X-originating-server" => $ec->{server});

  #printf("Request: %s\n", $request->as_string());
  my $response = $userAgent->request($request);
  if ($response->is_success) {
      #print "Successfully synced up manifest for $gav\n";
  } else {
    print "ERROR: couldn't publish manifest for $gav\n";
    print $response->status_line . "\n\n";
    $ec->setProperty("outcome", "error");
    $error++;
    return;
  }
  close FH;
  print "  Successfully synced up $gav\n";

  printf("\n");
  $sync++;
}


# ------------------------------------------------------------------------
# createUserAgent
#
#      Create and initialize an LWP::UserAgent.
#
# Arguments:
#      None.
# ------------------------------------------------------------------------
sub createUserAgent {
    $userAgent = LWP::UserAgent->new();
    my $connCache = LWP::ConnCache->new();
    my $httpCookies = HTTP::Cookies->new();
    $userAgent->conn_cache($connCache);
    $userAgent->cookie_jar($httpCookies);

    # Check for proxy (in a Zone for example)
    $httpProxy = $ec->getEnv("COMMANDER_HTTP_PROXY");
    if ($httpProxy) {
        $userAgent->proxy(https => $httpProxy);
        $userAgent->proxy(http => $httpProxy);
    }
}

# ------------------------------------------------------------------------
# createFilter
#
#      Create a findObjects filter (one-arg operator type).
#
# Arguments:
#      prop      - Property name.
#      op        - Operator
#      value     - The value to compare.
# ------------------------------------------------------------------------
sub createFilter {
    my ($prop, $op, $value) = @_;
    return {propertyName => $prop,
            operator => $op,
            operand1 => $value};
}

# ------------------------------------------------------------------------
# parseVersionRange
#
#      Parse a version range string to determine lower-bound, upper-bound,
#      and whether or not it's inclusive on either end.
#
# Arguments:
#      versionRange - the version range.
# ------------------------------------------------------------------------
sub parseVersionRange {
    my ($versionRange) = @_;
    if ($versionRange !~ m&^([\[\(])([^,\]\)]*),?([^,\]\)]*)([\]\)])$&) {
        die("version range $versionRange is not valid.\n");
    }
    return ($2, $1 eq "[", $3, $4 eq "]");
}

# ------------------------------------------------------------------------
# parsePatterns
#
#      Parse the gav-patterns array and return an array of findObjects
#      filters.
#
# Arguments:
#      None.
# ------------------------------------------------------------------------
sub parsePatterns {
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
      if (!defined($patComponent) || $patComponent eq "*" || $patComponent eq "") {
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
               createFilter($idx, $lowerInc ? "greaterOrEqual" : "greaterThan",
                            $lowerBnd),
             );
        }
        if (defined($upperBnd) && $upperBnd ne "") {
          push(@gavFilter,
               createFilter($idx, $upperInc ? "lessOrEqual" : "lessThan",
                            $upperBnd),
             );
        }
      } else {
        push(@gavFilter, createFilter($idx, "equals", $patComponent));
      }
    }

    if (@gavFilter > 0) {
        push(@filters, {operator => "and", filter => \@gavFilter} );
    }
  }

  return @filters;
}


# ------------------------------------------------------------------------
# checkArtifactVersion
#
#      Check to see if the artifact version exist in the target Repo
#
# Arguments:
#      $groupId, $artifactKey, $version
# Return:
#       0 or 1
# ------------------------------------------------------------------------
sub checkArtifactVersion ($$$) {
  my ($groupId, $artifactKey, $version) = @_;

  my $repoUrl = $targetRepoUrl . "/artifacts/$groupId/$artifactKey/$version";

  # Construct the commander-session auth header.
  my $authorization = "Basic " . encode_base64("commanderSession:" . $ec->{sessionId});
  my $request = HEAD $repoUrl, "Authorization" => $authorization, "X-originating-server" => $ec->{server};
  my $res = $userAgent->request($request);

  if ($res->is_success) {
    # printf("Artifact version (%s:%s:%s was found in target.\n", $groupId, $artifactKey, $version);
    return  1;
  }
  printf("Artifact version %s:%s:%s was NOT found in target.\n", $groupId, $artifactKey, $version);
  return  0;
}

# ------------------------------------------------------------------------
# checkARepoNames
#
#      Check to see if the artifact repo names are valid
#
# Arguments:
#      None
# Return:
#       None: exist in case of error
# ------------------------------------------------------------------------
sub checkRepoNames() {
  my $msg="";

  foreach my $repo (($sourceRepo,$targetRepo)) {
    my ($ok, $xml)=InvokeCommander(
      "IgnoreError SuppressLog", 'getRepository', $repo);
    if (!$ok) {

      $msg=sprintf("Artifact Repository '%s' does not exist!", $repo);
      $ec->setProperty("summary", $msg);
      printf("$msg\n");
      exit(1);
    }
    if ($xml->findvalue('/responses/response/repository/repositoryDisabled')) {
      $msg=sprintf("Artifact Repository '%s' is disabled!", $repo);
      $ec->setProperty("summary", $msg);
      printf("$msg\n");
      exit(1);
    }
   }
}

#############################################################################
#
#  Main
#
#############################################################################
createUserAgent();
checkRepoNames();

$gAM->loadRepositoryInfo();
if ($httpProxy) {
  $targetRepoUrl="https://$targetRepo";
  $sourceRepoUrl="https://$sourceRepo"
} else {
  $targetRepoUrl=$gAM->{repoUrl}->{$targetRepo};
  $sourceRepoUrl=$gAM->{repoUrl}->{$sourceRepo};
}

#printf ("Source Repo=%s\n", $sourceRepoUrl);
#printf ("Target Repo=%s\n", $targetRepoUrl);

# Find artifact versions in the server that match the given criteria
my @filters = ({propertyName => "artifactVersionState",
                    operator => "notEqual",
                    operand1 => "publishing"});

my @gavFilters = parsePatterns();
if (@gavFilters > 0) {
  push(@filters, {operator => "or", filter => \@gavFilters});
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

    # Check if gav is already in target repo
    if (checkArtifactVersion($artifactVersion->groupId, $artifactVersion->artifactKey,
                             $artifactVersion->version)) {
     printf("Found %s:%s:%s in repository\n", $artifactVersion->groupId,
              $artifactVersion->artifactKey, $artifactVersion->version);
    } else {
      downloadArtifactVersion($artifactVersion->groupId,
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
    $xpath = $ec->getObjects({objectId => \@objectIds});
  }
} while ($count > 0);

$ec->setProperty("summary", "$sync artifact versions synchronized");

# Set status as error if we encountered any issue
$ec->setProperty("summary", "$error synchronization errors detected") if ($error);

$[/plugins[EC-Admin]project/scripts/perlLib]










