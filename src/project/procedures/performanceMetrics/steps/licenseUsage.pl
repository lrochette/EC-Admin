$[/myProject/scripts/perlHeaderJson]

my $res=$ec->getLicenseUsage()->{responses}->[0]->{licenseUsage};
print Dumper($res);
my $str="";

#
# Concurrent Resources
#
if ($res->{concurrentResources}->{maxHosts} ne 'unlimited') {
  $str .= sprintf("%d of %d hosts\n", $res->{concurrentResources}->{inUseHosts}, $res->{concurrentResources}->{maxHosts}); 
}
if ($res->{concurrentResources}->{maxProxiedHosts} ne 'unlimited') {
  $str .= sprintf("%d of %d proxies\n", $res->{concurrentResources}->{inUseProxiedHosts}, $res->{concurrentResources}->{maxProxiedHosts}); 
}

print $res->{concurrentSteps}->{maxConcurrentSteps};
#
# Concurrent Steps
#
if ($res->{concurrentSteps}->{maxConcurrentSteps} ne 'unlimited') {
  $str .= sprintf("%d of %d steps\n", $res->{concurrentSteps}->{runningSteps}, $res->{concurrentSteps}->{maxConcurrentSteps}); 
}

#
# Concurrent users
#
if ($res->{concurrentUsers}->{maxLicenses} != 999999) {
  $str .= sprintf("%d of %d users\n", $res->{concurrentUsers}->{inUseLicenses}, $res->{concurrentUsers}->{maxLicenses}); 
}
$ec->setProperty("summary", $str);













