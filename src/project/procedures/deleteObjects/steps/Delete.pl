use strict;
use warnings;
use ElectricCommander;
use DateTime;
use POSIX;

$| = 1;

my $olderThan = DateTime->now()->subtract(days => "$[daysLimit]")->iso8601() . ".000Z";
my $interval = floor($[chunkSize] / 20);
# Maximum 60 seconds interval between checks no matter how large the chunk size is.
if ($interval > 60) {
    $interval = 60;
}

if ($[maxObjects] < $[chunkSize]) {
    print STDERR "Error: maxObjects must be at least as large as chunkSize";
    exit 1;
}

print "Chunk size: $[chunkSize]\nDays limit: $[daysLimit]\n"
    . "Max objects: $[maxObjects]\nObject type: $[objectType]\n"
    . "Poll interval: $interval" . "s\n\n";

my $ec = new ElectricCommander;

my $numReturned;
my $numDeleted = 0;
my $numChunks = 0;
my $overallStart = time();
my %deletedObjects = ();
do {
    $numChunks ++;
    my $maxIds = $[chunkSize] > ($[maxObjects] - $numDeleted) ? $[maxObjects] - $numDeleted : $[chunkSize];
    my $result = $ec->deleteObjects("$[objectType]", {
        maxIds     => $maxIds,
        filter     => [{
            propertyName => "finish",
            operator     => "lessThan",
            operand1     => $olderThan
        }],
        sort => [{
            propertyName => "finish",
            order => "ascending"
        }]
    });

    $numReturned = $result->findnodes("/responses/response/objectId")->size();
    $numDeleted += $numReturned;

    foreach my $objectIdNode ($result->findnodes("/responses/response/objectId")) {
        my $objectId = $objectIdNode->string_value;
        if (exists($deletedObjects{$objectId})) {
            my $error = "Error: $objectId is being deleted again";
            $ec->setProperty("summary", $error);
            print STDERR $error;
            exit 1;
        }
        $deletedObjects{$objectId} = 1;
    }

    if ($numReturned > 0) {
        print "Waiting for $numReturned $[objectType]s to be deleted...\n";
        my $lastId = $result->find("/responses/response/objectId[$numReturned]")->string_value;
        $ec->abortOnError(0);
        my $lastObject;
        do {
            sleep $interval;
            $lastObject = $ec->getObjects({objectId=>[$lastId]});
        } while ($lastObject->findvalue("/responses/response/object/objectId"));
        $ec->abortOnError(1);
        my $overallTime = time() - $overallStart;
        my $percent = ceil(($numDeleted / $[maxObjects]) * 100);
        my $summary = "Deleted $numDeleted $[objectType]s ($percent%) | "
            . sprintf("Total average deletion time: %.2fs", $overallTime / $numDeleted);
        $ec->setProperty("summary", $summary);
        print "$summary\n";
    }
} while ($numReturned > 0 && $[maxObjects] - $numDeleted > 0);

if ($numDeleted == 0) {
    $ec->setProperty("summary", "No $[objectType]s to delete");
}
