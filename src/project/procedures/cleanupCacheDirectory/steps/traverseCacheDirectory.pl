$[/myProject/scripts/perlHeader]

use ElectricCommander::Batch;
use Data::Dumper;

sub getContents($) {
    my ($dir) = @_;
    opendir(DIR, $dir) or die "ERROR: Couldn't open directory \"$dir\".\n";
    my @contents = readdir(DIR);
    closedir(DIR);
    return @contents;
}

# Keep track of whether we found any candidates for time or space based deletion.
$ec->setProperty("/myJob/candidatesForDeletion", {value => 0});

# Get the value of the actualCacheDirectory property.
my $cache = $ec->getProperty("actualCacheDirectory")->findvalue("//value");

# Create a new parallel batch of getArtifactVersion requests. Use parallel mode
# because we need to allow non-existent artifact versions, and single mode will
# have a cascaded failure at the first error it encounters.
my $gavBatch = $ec->newBatch('parallel');

# Create a map of GAV => requestId so we can get the appropriate response and
# store the needed data.
my %gavMap = ();

foreach my $g (getContents($cache)) {
    # First level = (g)roup
    if ($g eq "." || $g eq ".." || ! -d "$cache/$g") {
        next;
    } else {
        foreach my $a (getContents("$cache/$g")) {
            # Second level = (a)rtifact
            if ($a eq "." || $a eq ".." || ! -d "$cache/$g/$a") {
                next;
            } else {
                foreach my $v (getContents("$cache/$g/$a")) {
                    # Third level = (v)ersion
                    if ($v eq "." || $v eq ".." || ! -d "$cache/$g/$a/$v") {
                        next;
                    } else {
                        # Check to see if "g:a:v" is an artifact version.
                        my $gav = "$g:$a:$v";
                        print "Potential artifact version: $gav\n";
                        my $reqId = $gavBatch->getArtifactVersion($gav,
                            {
                                includeRetrieverJobSteps => 1,
                                maxRetrievers => 1
                            }
                        );
                        $gavMap{$gav} = $reqId;
                    }
                }
            }
        }
    }
}

if (keys %gavMap == 0) {
    print "No potential GAV directories were found in \"$cache\".\n";
    exit 0;
}

# Allow "no such aritfact version" errors.
$ec->abortOnError(0);
$gavBatch->submit();
$ec->abortOnError(1);

# Create a new parallel batch of getProperty requests.
my $stepBatch = $ec->newBatch('single');

foreach my $gav (keys %gavMap) {
    my $reqId = $gavMap{$gav};
    my $jobStepId = $gavBatch->findvalue($reqId, "artifactVersion/retriever/jobStepId")->string_value;
    if ($jobStepId ne "") {
        print "Artifact version \"$gav\" was last retrieved by job step $jobStepId.\n";
        my $reqId = $stepBatch->getProperty("/jobSteps/$jobStepId/start");
        $gavMap{$gav} = $reqId;
    } else {
        # Remove this artifact version from our map if no job step id was found,
        # which would happen if the artifact was never retrieved in a job context.
        delete $gavMap{$gav};
    }
}

if (keys %gavMap == 0) {
    print "No potential GAV directories were retrieved by job steps.\n";
    exit 0;
}

$stepBatch->submit();

# Get the start times for the last job step to access each artifact version and store
# the artifact version => last access time in a property sheet on the job for future
# steps to consume.
foreach my $gav (keys %gavMap) {
    my $reqId = $gavMap{$gav};
    my $start = $stepBatch->findvalue($reqId, "property/value")->string_value;
    $ec->setProperty("/myJob/validArtifactVersions/$gav", {value => $start});
}

$ec->setProperty("/myJob/candidatesForDeletion", {value => 1});

