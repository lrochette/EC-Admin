$[/myProject/scripts/perlHeader]

use warnings;
use File::Spec;

my $executeDeletion="$[executeDeletion]";
my $response;

my $dataEnv = "COMMANDER_DATA";
my $dataDir;

if (defined($ENV{$dataEnv})) {
    $dataDir = $ENV{$dataEnv};
    print "Data directory found in environment: \"$dataDir\".\n";
} else {
    # No data directory in the environment; probably a pre-4.0 agent.
    die "ERROR: No data directory was found in the environment.\n";
}

if (! -d $dataDir) {
    # The data directory is invalid.
    die "ERROR: Cannot access data directory \"$dataDir\".\n";
}

my $propsFile = "$dataDir/conf/repository/server.properties";
if (! -f $propsFile) {
    # There's no repository server.properties.
    die "ERROR: Cannot find repository configuration file \"$propsFile\".\n";
}

open PROPS, $propsFile or die "Could not open repository configuration file \"$propsFile\": $!";
binmode PROPS;
my $propsContents = join("", <PROPS>);
close PROPS;
$propsContents =~ m/REPOSITORY_BACKING_STORE=([^\n]*)/;
my $backingStore = $1;

if (!defined($backingStore) || $backingStore eq "") {
    # Invalid backing store.
    die "ERROR: Cannot find backing store in repository configuration file \"$propsFile\".\n";
}

# If the backing store isn't an absolute path, it is relative to the data directory.
if (!File::Spec->file_name_is_absolute($backingStore)) {
    $backingStore = "$dataDir/$backingStore";
}

if (! -d $backingStore) {
    # The backing store directory is invalid.
    die "ERROR: Cannot access backing store directory \"$backingStore\".\n";
}

if ($executeDeletion eq "true") {
    # Get Admin user/password from project-level credential
    # getFullCredential will not reveal the contents of the "password" field
    my $xPath = $ec->getFullCredential("adminLogin");
    my $user = $xPath->findvalue("//userName");
    my $passwd = $xPath->findvalue("//password");

    print "Cleaning up repository backing store \"$backingStore\".\n";
    $ec->login($user, $passwd);
    $ec->cleanupRepository($backingStore);
} else {
    print "Would call cleanupRepository on \"$backingStore\".\n";
}


