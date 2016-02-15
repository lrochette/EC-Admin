$[/myProject/performances/scripts/perf.pm]

#
# Parameters
#
my $hostname="$[hostname]";
my $resource="$[resource]";

#
# Global Variables
# 
my $pingCount=5;
my $avgPing=0;
my $result;
my $str;

if ($OSNAME eq "linux") {
  $result=`ping -c $pingCount -q $hostname | tail -1`;

  if ($result =~ /rtt/) {
    # rtt min/avg/max/mdev = 0.167/0.190/0.238/0.027 ms
    $result =~ m#[\d\.]+/([\d\.]+)/[\d\.]+/[\d\.]+#;
    $avgPing=$1;
  } elsif ($result =~ /unknown host/) {
    InvokeCommander("SuppressLog", "setProperty", "outcome", "warning");
    InvokeCommander("SuppressLog", "setProperty", "summary", "$hostname unknown");
    exit(2);
  } else {
    # unreachable host
    InvokeCommander("SuppressLog", "setProperty", "outcome", "warning");
    InvokeCommander("SuppressLog", "setProperty", "summary", "$hostname unreachable");
    exit(1);
  }
  $str=sprintf("%s: %4.3f ms\n", $hostname, $avgPing);
} else {   # Windows
  $result=`C:/Windows/system32/ping -n $pingCount $hostname`;
  
  if ($result =~ /Minimum/) {
    #  Minimum = 178ms, Maximum = 530ms, Average = 357ms
    $result =~ m/Average = (\d+)ms/;
    $avgPing=$1;
  } elsif ($result =~ /could not find host/) {
    InvokeCommander("SuppressLog", "setProperty", "outcome", "warning");
    InvokeCommander("SuppressLog", "setProperty", "summary", "$hostname unknown");
    exit(2);
  } else {
    # unreachable host
    InvokeCommander("SuppressLog", "setProperty", "outcome", "warning");
    InvokeCommander("SuppressLog", "setProperty", "summary", "$hostname unreachable");
    exit(1);
  }
  $str=sprintf("%s: %d ms\n", $hostname, $avgPing);
}

checkValue("PING", $avgPing, $str);











