$[/myProject/scripts/perlHeader]

# Logging verbosity - 0 for quiet, 1 for more logging information
my $verbose = 0;

# Build a hash of "interesting" statistics to collect and save.
# The hash key is the name of the statistic, and the value is the xpath
# query string used to retrieve the statistic from the getLicenseUsage() API.
my $xprefix = '/responses/response/licenseUsage/';
my %statXPaths = (
    'inUseHosts' => $xprefix . 'concurrentResources/inUseHosts',
    'inUseProxiedHosts' => $xprefix . 'concurrentResources/inUseProxiedHosts',
    'runningSteps' => $xprefix . 'concurrentSteps/runningSteps',
    'inUseLicenses' => $xprefix . 'concurrentUsers/inUseLicenses',
);


# We need to know our server's identity
my $xp = $ec->getProperty('/server/hostName');
my $identity = $xp->findvalue('//value')->string_value;
print "identity: $identity\n" if ($verbose);

# We need to know our project name
my $projName = "EC-Admin";
print "projName: $projName\n" if ($verbose);

# Determine "now", as defined by the Commander server
$xp = $ec->getProperty('/timestamp yyyyMMddHHmmss');
my $timeStamp = $xp->findvalue('//value')->string_value;
print "timeStamp: $timeStamp\n" if ($verbose);

# Fetch a snapshot of current license usage data
$xp = $ec->getLicenseUsage();

# Extract the stats from the returned XML
my %statValues = ();
foreach my $i (keys %statXPaths) {
    $statValues{$i} = $xp->findvalue($statXPaths{$i})->string_value;
    printf("%18s: %s\n", $i, $statValues{$i}) if ($verbose);
}

# Save the stats to the current job as individual properties
# (intended for testing and for reporting using the normal reporting tools)
print "Saving stats to /myJob...\n" if ($verbose);
$ec->setProperty('/myJob/timeStamp', $timeStamp, {'expandable'=>0});
$ec->setProperty('/myJob/identity', $identity, {'expandable'=>0});
foreach my $i (keys %statValues) {
    $ec->setProperty("/myJob/$i", $statValues{$i}, {'expandable'=>0});
}
print "Successfully saved stats to /myJob\n" if ($verbose);

# Format the header record and data record in simple CSV format.
my $dataVersion = 'v0';
my $hdrLine = "identity,dataVersion,timeStamp";
my $logLine = "$identity,$dataVersion,$timeStamp";
foreach my $i (sort keys %statValues) {
    $hdrLine .= ',' . $i;
    $logLine .= ',' . $statValues{$i};
}
print "Data header: \"$hdrLine\"\n record: \"$logLine\"\n" if ($verbose);

# Save the stats to the system propertySheet. A major consideration is that
# we do not want to create too many individual properties, and neither do we
# wish to create overly-large properties - one per month should be reasonable.
print "Saving stats to server sheet\n" if ($verbose);
my $logProp = substr($timeStamp, 0, 6);
my $logPN = "/server/$projName/licenseLogger/$logProp";
print " getProperty \"$logPN\"\n" if ($verbose);
$xp = $ec->getProperty("/javascript getProperty(\"$logPN\");");
my $v = $xp->findvalue('//value')->string_value;
if ($v) {
    print " existing property...\n" if ($verbose);
    $ec->setProperty($logPN, $v . "\n$logLine");
} else {
    print " new property...\n" if ($verbose);
    $ec->setProperty($logPN, "$hdrLine\n$logLine",
         {'expandable'=>0, 'description'=>$hdrLine});
}
print "Successfully saved stats to server sheet\n" if ($verbose);

# Optionally, save the stats to a log file - use the same format as above.
$xp = $ec->getProperty('/javascript getProperty("/myProject/config/logPath");');
my $logPath = $xp->findvalue('//value')->string_value;
if ($logPath) {
    print "Saving stats to filesystem...\n" if ($verbose);
    my $ln = $logPath . '/' . $logProp;
    my $lv = (-f $ln) ? "$logLine\n" : "$hdrLine\n$logLine\n";
    print " opening \"$ln\"...\n" if ($verbose);
    open(PN, ">>$ln") || die "$ln: Unable to open for appending: $!\n";
    print PN "$lv";
    close PN;
    print "Successfully saved stats to filesystem.\n" if ($verbose);
} else {
    print "No log file path, not saving to filesystem.\n" if ($verbose);
}

# Done.
exit 0;

##########################################################################
# XML response from getLicenseUsage() looks like this (Commander v4.2.3):
#<responses>
# <response requestId="1">
# <licenseUsage>
# <concurrentResources>
# <inUseHosts>1</inUseHosts>
# <inUseProxiedHosts>0</inUseProxiedHosts>
# <maxHosts>60</maxHosts>
# <maxProxiedHosts>10</maxProxiedHosts>
# </concurrentResources>
# <concurrentSteps>
# <maxConcurrentSteps>unlimited</maxConcurrentSteps>
# <runningSteps>1</runningSteps>
# </concurrentSteps>
# <concurrentUsers>
# <adminLicenseUser />
# <inUseLicenses>0</inUseLicenses>
# <maxLicenses>unlimited</maxLicenses>
# </concurrentUsers>
# </licenseUsage>
# </response>
#</responses>
########################################################################





