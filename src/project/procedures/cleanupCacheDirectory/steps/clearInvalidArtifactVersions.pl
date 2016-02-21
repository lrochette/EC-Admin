$[/myProject/scripts/perlHeader]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $executeDeletion= "$[executeDeletion]";

# We're going to try and find a valid cache directory. Mark the directory as invalid for now
# and update it only once we find and validate the directory.
$ec->setProperty("/myJob/cacheDirectoryIsValid", {value => 0});

# Check the environment variable COMMANDER_ARTIFACT_CACHE.
my $cacheEnv = "COMMANDER_ARTIFACT_CACHE";
my $dir;
if (defined($ENV{$cacheEnv})) {
    $dir = $ENV{$cacheEnv};
    print "Cache directory found in environment: \"$dir\".\n";
} else {
    # We came up empty; give up since we don't know what directory to cleanup.
    warn "ERROR: No cache directory was found in the environment.\n";
    $ec->setProperty("outcome", "warning");
    $ec->setProperty("summary", "No cache directory");
    exit(0);
}

if (! -d $dir) {
    # The directory can't be read; no need to try to clean it up.
    warn "ERROR: Cannot access directory \"$dir\".\n";
    $ec->setProperty("outcome", "warning");
    $ec->setProperty("summary", "Cache directory does not exit");
    exit(0);
}

$ec->setProperty("/myJob/actualCacheDirectory", {value => $dir});
$ec->setProperty("/myJob/cacheDirectoryIsValid", {value => 1});
if ($executeDeletion eq "true") {
    print "Cleaning up artifact cache.\n";
    $ec->cleanupArtifactCache($dir, {'force' => 1});
} else {
    print "Would call cleanupArtifactCache on \"$dir\".\n";
}

















