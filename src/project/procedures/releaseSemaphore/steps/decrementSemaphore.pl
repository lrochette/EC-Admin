$[/myProject/scripts/perlHeader]

my $xPath = $ec->incrementProperty("$[semaphoreProperty]", -1);
my $semaphore = $xPath->findvalue('//value')->string_value;
$ec->setProperty("summary", "semaphore = $semaphore");

# Decrement local counter as well
my $xPath = $ec->incrementProperty("/myJob/localSemaphoreCounter", -1);











