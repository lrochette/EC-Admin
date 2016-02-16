$[/myProject/performances/scripts/perf.pm]

#
# Parameters
#
my $hostname="$[hostname]";
my $resource="$[resource]";


my $start = time();
for (my $i=0; $i < 4469134; $i++) {dec2bin(3);}
my $totalTime = time()-$start;

my $str=sprintf("%s: %d s\n", $hostname, $totalTime);
checkValue("PERF", $totalTime, $str);
exit(0);


# 2004
# Xah
# xah@xahlee.org
# http://xahlee.org/

# convert to/from binary
sub dec2bin {
  my $str = unpack ("B32", pack("N", shift ));
  $str =~ s@^0+(?=\d)@@; # otherwise you'll get leading zeros
  return $str;
}













