# Copyright (c) 2005-2015 Electric Cloud, Inc.
# All rights reserved.

# TODO: Warnings for bad repo names, or errors connecting to repos.
#       Include repo names, timestamps in success messages.
#       General walk through and make sure errors are reported when they
#       should be.

use strict 'vars';
use strict 'subs';
use ElectricCommander;
use XML::XPath;
use ElectricCommander::ArtifactManagement;
use ElectricCommander::ArtifactManagement::ArtifactVersion;

use File::Path;
use File::Spec;
use Getopt::Long;
use HTTP::Cookies;
use LWP::ConnCache;
use LWP::UserAgent;
use HTTP::Request::Common qw(GET);
use MIME::Base64;
use URI::Escape;

# ------------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------------

$::gCommander = undef;
$::gAM = undef;
$::gFromRepositoryNames = "$[artifactRepositoryList]";
@::gGavPatterns = split(",", "$[artifactRepositoryPattern]");
$::gServer = undef;
$::gUserAgent = createUserAgent();
$::gHelp = 0;

# ------------------------------------------------------------------------
# createUserAgent
#
#      Create and initialize an LWP::UserAgent.
#
# Arguments:
#      None.
# ------------------------------------------------------------------------

sub createUserAgent
{
    my $userAgent = LWP::UserAgent->new();
    my $connCache = LWP::ConnCache->new();
    my $httpCookies = HTTP::Cookies->new();
    $userAgent->conn_cache($connCache);
    $userAgent->cookie_jar($httpCookies);
    return $userAgent;
}

# ------------------------------------------------------------------------
# downloadArtifactVersion
#
#      Download the given artifact version from one of the given
#      repository urls.
#
# Arguments:
#      repoUrls - array-ref of repository base urls.
#      groupId
#      artifactKey
#      version
#      repositoryDir - Directory to download artifact version into
#              (e.g. /data/g1/a1/1.0.0).
# ------------------------------------------------------------------------

sub downloadArtifactVersion($$$$$)
{
    my ($repoUrls, $groupId, $artifactKey, $version, $repositoryDir) = @_;

    # TODO: Check errors here.
    mkpath($repositoryDir);

    my $gav = "$groupId:$artifactKey:$version";
    # TODO: Write to a temp dir, then rename.
    foreach my $repoUrlBase (@$repoUrls) {
        my $repoUrl = "$repoUrlBase/artifacts/$groupId/$artifactKey/$version";
        my $authorization = "Basic " .
            encode_base64("commanderSession:" . $::gCommander->{sessionId});
        my $request = GET $repoUrl, "Authorization" => $authorization;
        my $response = $::gUserAgent->request($request, $repositoryDir .
                                                  "/artifact");

        if ($response->is_success) {
            print "Successfully synced down $gav\n";
            my $fmt = $response->header("Format");
            if (!defined($fmt)) {
                print "WARNING: Could not determine artifact format; leaving " .
                    "contents of $repositoryDir around for manual analysis.\n";
            }
            rename($repositoryDir . "/artifact",
                   $repositoryDir . "/artifact.$fmt");

            # Get the manifest file.
            $request = GET $repoUrl . "?manifest",
                "Authorization" => $authorization;
            $::gUserAgent->request($request, $repositoryDir .
                                                  "/manifest");
            if ($response->is_success) {
                # Success! Log a message and return.
                print "Successfully synced down manifest for $gav\n";
                return;
            }

            # All errors are significant.
            print("ERROR: couldn't sync down manifest for $gav: " .
                      $response->content);
            return;
        } else {
            # Some error occurred.

            if ($response->code() == 403) {
                # We got a Forbidden! This means we lack permissions. If we
                # don't have permission with one repo, we won't have permission
                # with any (since they all talk to the same Commander server).

                print "ERROR: couldn't retrieve $gav: access denied\n";
                return;
            }

            # Log it in diagnostics and move on; don't log 404's since we don't
            # expect all repos to have all artifacts in a normal running system.

            if ($response->code != 404) {
                print "WARNING: couldn't retrieve $gav from $repoUrlBase: " .
                          $response->content;
            }
        }
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

sub createFilter($$$)
{
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

sub parseVersionRange
{
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

sub parsePatterns
{
    my @filters = ();
    foreach my $pat (@::gGavPatterns) {
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

# ------------------------------------------------------------------------
# findBackingStorePath
#
#      Reads the server.properties file in data-dir/conf/repository
#      and returns the REPOSITORY_BACKING_STORE value.
#
# Arguments:
#      None.
# ------------------------------------------------------------------------

sub findBackingStorePath
{
    if (!exists($ENV{COMMANDER_DATA})) {
        die(<<EOF);
COMMANDER_DATA environment variable is not set; this script must run in a
step or this environment variable must point to the Commander data directory.
EOF
    }

    my $propFile = $ENV{COMMANDER_DATA} . "/conf/repository/server.properties";
    open PROPFILE, "< $propFile" or die("Couldn't open $propFile: $!\n");
    my $backingStorePath = undef;
    while(my $line = <PROPFILE>) {
        if ($line =~ /^\s*REPOSITORY_BACKING_STORE\s*=\s*(.*)\s*$/) {
            $backingStorePath = $1;
            last;
        }
    }
    close(PROPFILE);

    # A few caveats here: it's possible that REPOSITORY_BACKING_STORE isn't set
    # at all (in which case we should error out) or it's a relative path
    # (which we should convert to absolute).

    if (!defined($backingStorePath) || $backingStorePath eq "") {
        die("REPOSITORY_BACKING_STORE property not defined in $propFile.\n");
    }
    $backingStorePath = File::Spec->rel2abs($backingStorePath,
                                            $ENV{COMMANDER_DATA});
    return $backingStorePath;
}

# ------------------------------------------------------------------------
# main
#
#      Main function that orchestrates the sync.
# ------------------------------------------------------------------------

sub main {
    my @repoNames = split(",", $::gFromRepositoryNames);

    # Locate our repository backingstore location.
    my $backingstorePath = findBackingStorePath();
    print "backingStorePath: $backingstorePath\n";
    $::gCommander = new ElectricCommander({server => $::gServer});
    $::gAM = new ElectricCommander::ArtifactManagement($::gCommander);

    # Find artifact versions in the server that match the given criteria
    my @filters = ({propertyName => "artifactVersionState",
                    operator => "notEqual",
                    operand1 => "publishing"});
    my @gavFilters = parsePatterns();
    if (@gavFilters > 0) {
        push(@filters, {operator => "or",
                        filter => \@gavFilters});
    }
    my $xpath = $::gCommander->findObjects("artifactVersion", {
        filter => \@filters,
        sort => [{propertyName => "groupId", order => "ascending"},
                 {propertyName => "artifactKey", order => "ascending"},
                 {propertyName => "version", order => "ascending"}
             ]
    });

    # Walk through returned artifact versions, checking if we have each in
    # the backingstore. If not, download from one of the repositories.

    my @repoUrlList = undef;
    my $didLoadRepos = 0;
    foreach my $node ($xpath->findnodes("//artifactVersion")) {
        my $artifactVersion =
            ElectricCommander::ArtifactManagement::ArtifactVersion->new(
                $node);
        my $repositoryDir = sprintf("%s/%s/%s/%s",
                                    $backingstorePath,
                                    $artifactVersion->groupId,
                                    $artifactVersion->artifactKey,
                                    $artifactVersion->version);
        if (! -d $repositoryDir) {
            # Download.
            if (!$didLoadRepos) {
                $::gAM->loadRepositoryInfo();
                my @verifiedRepoList =
                    $::gAM->processRepositoryNames(\@repoNames);
                @repoUrlList = map {$::gAM->{repoUrl}->{$_}} @verifiedRepoList;
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
}

main();

