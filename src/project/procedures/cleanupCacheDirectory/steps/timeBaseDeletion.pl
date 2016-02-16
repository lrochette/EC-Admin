$[/myProject/scripts/perlHeader]

use ElectricCommander::Batch;
use File::Path;
use Time::Local;

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $days=$[olderThan];
my $executeDeletion="$[executeDeletion]";

# Get the value of the actualCacheDirectory property.
my $cache = $ec->getProperty("actualCacheDirectory")->findvalue("//value");

# Create a new parallel batch of deleteProperty requests for all artifact versions
# that we are blowing away, so the /myJob/validArtifactVersions property sheet is
# up to date for future steps that consume it.
my $deleteBatch = $ec->newBatch('parallel');

# Figure out the time limit for deletion based on the number of days specified.

my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(time() - (3600*24*$days));
my $timeLimit = sprintf("%4d%02d%02d%02d%02d%02d", 1900+$year,
                      $mon+1, $mday, $hour, $min, $sec);
print "Time limit for deletion: $timeLimit\n";

# Get the properties stored in /myJob/validArtifactVersions so we can go through
# each one to figure out if we should delete it.
my $validVersions = $ec->getProperties({path => "/myJob/validArtifactVersions"});

foreach my $validVersion($validVersions->findnodes("//property")) {
    my $accessTime = $validVersion->findvalue("value")->string_value;
    $accessTime =~ s/[^.\d]//g;
    if ($accessTime < $timeLimit) {
        my $gav = $validVersion->findvalue("propertyName")->string_value;
        $gav =~ m/(.*):(.*):(.*)/;
        my $dir = "$cache/$1/$2/$3";
        if ($executeDeletion eq "true") {
            print "Deleting \"$dir\" (last accessed $accessTime).\n";
            rmtree($dir);
        } else {
           print "Would delete \"$dir\" (last accessed $accessTime).\n";
        }
    }
}













