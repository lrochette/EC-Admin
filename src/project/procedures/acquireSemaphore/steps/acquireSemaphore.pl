use strict;
use ElectricCommander;
$| = 1;

my $ec = new ElectricCommander;
my $xPath = $ec->getProperty("$[semaphoreProperty]");
my $semaphore = $xPath->findvalue('//value')->string_value;
print "First eval: semaphore = $semaphore\n";

while ($semaphore >= $[maxSemaphoreValue]){
  $ec->setProperty("summary", "Waiting for Semaphore");
  sleep(5);
  $xPath = $ec->getProperty("$[semaphoreProperty]");
  $semaphore = $xPath->findvalue('//value')->string_value;
  print "in loop: semaphore = $semaphore\n";
}

# When we get here, a token is available. Acquire it.
my $xPath = $ec->incrementProperty("$[semaphoreProperty]");

# Increment local counter as well
my $xPath = $ec->incrementProperty("/myJob/localSemaphoreCounter");

$ec->setProperty("summary", "Semaphore acquired");











