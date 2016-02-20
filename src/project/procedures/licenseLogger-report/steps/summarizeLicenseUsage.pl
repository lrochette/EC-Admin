use Archive::Zip;
$[/myProject/scripts/perlHeader]


# Debugging verbosity: 0 for quiet, 1 for normal, 2 for debug
my $verbose = 1;

# and our server's host name
my $xp = $ec->getProperty('/server/hostName');
my $hostName = $xp->findvalue('//value')->string_value;

# We may need some email configuration properties as well
$xp = $ec->getProperty(
    '/javascript getProperty("/server/EC-Admin/licenseLogger/config/emailConfig");');
my $emailConfig = $xp->findvalue('//value')->string_value;

$xp = $ec->getProperty(
    '/javascript getProperty("/server/EC-Admin/licenseLogger/config/emailTo");');
my $v = $xp->findvalue('//value')->string_value;

# Split email list on commas and/or semicolons, then remove white space
my @emailTo = ();
foreach (split /[,;]/, $v) {
    s/^\s*//;
    s/\s*$//;
    push @emailTo, $_;
}

# optional zipped log filename (used only when mailers strip zip files)
$xp = $ec->getProperty(
    '/javascript getProperty("/server/EC-Admin/licenseLogger/config/attachmentName");');
my $zipFN = $xp->findvalue('//value')->string_value;

# Get a license usage to get max values for header
# Build a hash of "interesting" statistics to collect and save.
# The hash key is the name of the statistic, and the value is the xpath
# query string used to retrieve the statistic from the getLicenseUsage() API.
my $xprefix = '/responses/response/licenseUsage/';
my %statXPaths = (
    'maxHosts' => $xprefix . 'concurrentResources/maxHosts',
    'maxProxiedHosts' => $xprefix . 'concurrentResources/maxProxiedHosts'
);
# Fetch a snapshot of current license usage data
$xp = $ec->getLicenseUsage();

# Extract the stats from the returned XML
my %statValues = ();
foreach my $i (keys %statXPaths) {
    $statValues{$i} = $xp->findvalue($statXPaths{$i})->string_value;
}

# Finally, fetch our parameters
$xp = $ec->getProperty('sendEmail');
my $sendEmail = $xp->findvalue('//value')->string_value;

$xp = $ec->getProperty('logName');
my $logName = $xp->findvalue('//value')->string_value;

# If the logName parameter is null, we need to compute the last log.
if (! $logName) {
    $xp = $ec->getProperty('/timestamp yyyyMM');
    my $yearMonth = $xp->findvalue('//value')->string_value;
    my $year = substr($yearMonth, 0, 4);
    my $month = substr($yearMonth, 4, 2);
    $month--;
    if ($month < 1) {
	$month = 12;
	$year--;
    }
    $logName = sprintf("%04d%02d", $year, $month);
}

# Set the property path, and the log and zip file names
my $logPN = "/server/EC-Admin/licenseLogger/$logName";
my $logFN = $logName . '.txt';
my $zipFN = $logName . '.zip' unless ($zipFN);

# Print some helpful information, if requested
if ($verbose) {
    print "INFO: logName:     \"$logName\"\n";
    print "INFO: logFN:       \"$logFN\"\n";
    print "INFO: zipFN:       \"$zipFN\"\n";
    print "INFO: property:    \"$logPN\"\n";
    print "INFO: sendEmail:   \"$sendEmail\"\n";
    print "INFO: emailConfig: \"$emailConfig\"\n";
    print "INFO: emailTo:     " . join('; ', @emailTo) . "\n";
}

# We will build up the report information in the $report varible
my $report = "License Usage Report\n";
$report .= " Input dataset: $logName\n";
$report .= " Generated on server: $hostName\n";

# Bare minimum email subject line (we will refine this if we have data)
my $subject = "License Usage Report";

# jobStep summary 
my $summary = undef;

# Number of records processed
my $n = 0;

# Read the value of the log property
$xp = $ec->getProperty("/javascript getProperty(\"$logPN\");");
my $v = $xp->findvalue('//value')->string_value;

# Process the data records we just read
if ($v) {

    # Save the property data to a file (for email later)
    open(PV,">$logFN") || die "$logFN: Unable to create: $!\n";
    print PV $v;
    close PV;

    # initialize the variables we'll use to accumulate information
    my $tstart = undef;
    my $tend = undef;
    my $host = undef;
    my %maxt = ();
    my %maxv = ();
    my %samples = ();

    # Iterate over each record (first one is the header), and locate the
    # peak values for each element in the comma-separated list.  The first
    # element is the host ID (IP or hostname), the second is the version
    # of the data record, and the third is the time stamp of the record.
    # The remaining elements may vary based on the version of the record
    # itself (which may be different for each record, although that would
    # be unusual).  For the case where the version number is missing, it is
    # assumed to be "v0".

    for (split /^/, $v) {

	# Remove any trailing LF characters, if they exist
	chomp;

	# Skip blank lines
	next unless ($_);

	# Skip any comment lines
	next if (/^#/);

	# Skip any header lines
	next if (/^identity.*timeStamp/);

	# Split the fields
	my @f = split ',', $_;

	# First field is always the hostname of the logging server
	my $h = shift(@f);

	# Handle version field specially, if absent handle as if it were v0
	my $ver = 'v0';
	if ($f[0] =~ m/^v/) {
	    $ver = shift(@f);
	}

	if ($ver eq 'v0') {
	    # v0 data record format:
	    #  identity,version,timeStamp,
	    #    inUseHosts,inUseLicenses,inUseProxiedHosts,runningSteps

	    # Extract the fields
	    my $t = shift(@f);
	    my $inUseHosts = shift(@f);
	    my $inUseLicenses = shift(@f);
	    my $inUseProxiedHosts = shift(@f);
	    my $runningSteps = shift(@f);

	    # determine the year/month/day for this record
	    $t =~ m/^(\d\d\d\d\d\d\d\d)/;
	    my $day = $1;
	    $samples{$day}++;

	    if ($n == 0) {
		# first data line - initialize all the maximum observed values,
		# save away the host identifier, and record the start time.

		$maxv{$day}{'inUseHosts'} = $inUseHosts;
		$maxt{$day}{'inUseHosts'} = $t;

		$maxv{$day}{'inUseLicenses'} = $inUseLicenses;
		$maxt{$day}{'inUseLicenses'} = $t;

		$maxv{$day}{'inUseProxiedHosts'} = $inUseProxiedHosts;
		$maxt{$day}{'inUseProxiedHosts'} = $t;

		$maxv{$day}{'runningSteps'} = $runningSteps;
		$maxt{$day}{'runningSteps'} = $t;

		$tstart = $t;
		$tend = $t;
		$host = $h;
	    } else {

		# For each of the rest of the records, save a new end time...
		$tend = $t;

		# ...and record a new max value if appropriate.
		if ($inUseHosts > $maxv{$day}{'inUseHosts'}) {
		    $maxv{$day}{'inUseHosts'} = $inUseHosts;
		    $maxt{$day}{'inUseHosts'} = $t;
		}

		if ($inUseLicenses > $maxv{$day}{$inUseLicenses}) {
		    $maxv{$day}{'inUseLicenses'} = $inUseLicenses;
		    $maxt{$day}{'inUseLicenses'} = $t;
		}

		if ($inUseProxiedHosts > $maxv{$day}{$inUseProxiedHosts}) {
		    $maxv{$day}{'inUseProxiedHosts'} = $inUseProxiedHosts;
		    $maxt{$day}{'inUseProxiedHosts'} = $t;
		}

		if ($runningSteps > $maxv{$day}{$runningSteps}) {
		    $maxv{$day}{'runningSteps'} = $runningSteps;
		    $maxt{$day}{'runningSteps'} = $t;
		}
	    }
	} else {
	    die "ERROR: Unknown data record version: $ver\n";
	}

	# Don't forget to increment the data record counter
	$n++;
    }

    # Build up the report - start with the subject line for the email.
    $subject .= " for $host from $tstart to $tend";

    # Now build the body of the email.
    $report .= " Data collected on server: $host\n";
    $report .= sprintf(" %d records from %s to %s\n", $n-1, $tstart, $tend);
    foreach my $i (sort keys %statValues) {
    	$report .= sprintf(" %-15s: %3d\n", $i, $statValues{$i});
	}
    $report .= " ----\n";

    # Field names to be reported upon (adjust as required)
    my @fieldNames = ('inUseHosts',
		      'inUseLicenses',
		      'inUseProxiedHosts',
		      'runningSteps');

    # Report header line
    $report .= 'Date        ';
    foreach my $f (@fieldNames) {
	$report .= sprintf(" %-17s", $f);
    }
    $report .= "\n";

    # Iterate over the field names to generate the report
    #foreach my $d (sort keys %maxv) {
    foreach my $d (sort keys %samples) {
	$d =~ m/^(\d\d\d\d)(\d\d)(\d\d)/;
	$report .= sprintf("%4s-%2s-%2s: ", $1, $2, $3);
	#for (my $i = 0; $i < scalar @{$maxv{$d}}; $i++) {
	#    my $v = $maxv{$d}[$i];
	#    my $f = '';
	#    if ($v) {
	#	$maxt{$d}[$i] =~ m/^\d\d\d\d\d\d\d\d(\d\d)(\d\d)(\d\d)/;
	#	$f .= sprintf(" %-4d @ %02d:%02d:%02d", $v, $1, $2, $3);
	#    }
	#    $report .= sprintf(" %-17s", $f);
	#}
	foreach my $f (@fieldNames) {
	    my $dp = '';
	    my $v = $maxv{$d}{$f};
	    if ($v) {
		$maxt{$d}{$f} =~ m/^\d\d\d\d\d\d\d\d(\d\d)(\d\d)(\d\d)/;
		$dp = sprintf("%-4d @ %02d:%02d:%02d", $v, $1, $2, $3);
	    }
	    $report .= sprintf(" %-17s", $dp);
	}
	$report .= "\n";
    }
    $report .= " ----\n";

    # Assemble the summary line for the job step
    $summary = sprintf("%d records processed\n %s - %s", $n, $tstart, $tend);

} else {
    # Record that we have no data to report... shouldn't happen normally.
    $report .= "\nERROR: No data to report.\n";
    $summary = "No records processed";
}

# If we're being verbose, print the email body out to the log
print "\n$report" if ($verbose);

# Attach the report as a property, just to make it easy to find the data
$ec->setProperty("/myJob/report", $report, {'expandable'=>0});

# Update the job step summary
$ec->setProperty("/myJobStep/postSummary", $summary);

# Optionally, send the report via email
if ($sendEmail && ($sendEmail ne 'false')) {
    print "DEBUG: Preparing to send email...\n" if ($verbose > 1);
    my %ehash = (
	'configName' => $emailConfig,
	'to'         => \@emailTo,
	'subject'    => $subject,
	'text'       => $report,
    );
    # attach the detailed log, if it exists
    if ($n) {
	my $zip = Archive::Zip->new();
	$zip->addFile($logFN);
	$zip->writeToFileNamed($zipFN);
	push @{$ehash{'attachment'}}, $zipFN;
    }
    $ec->sendEmail(\%ehash);
}

# Done.
exit 0;

# Function to return number of days in a specific month
sub daysInMonth($$) {
    my $year = shift;
    my $month = shift;
    my $isLeapYear = ($year % 4) ||
	(($year % 100 == 0) && ($year % 400)) ? 0 : 1;
    my $d = 31 - (($month == 2) ?
		  (3 - $isLeapYear) : (($month - 1) % 7 % 2));
    return $d;
}















