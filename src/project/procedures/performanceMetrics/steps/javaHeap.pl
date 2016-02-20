$[/myProject/performances/scripts/perf.pm]
$DEBUG=1;

my $wrapperFile="$[/server/Electric Cloud/dataDirectory]/conf/wrapper.conf";
my $javaInitMem=0;
my $javaMaxMem=0;

open FILE, "< $wrapperFile" || die "Cannot open the file $wrapperFile\n";
while (<FILE>) {
  next if /^#/;
  # 
  # Let's look at init memory value that is not commented
  if (/^wrapper.java.initmemory/) {
    if (/\.percent/) {
      # wrapper.java.initmemory.percent=20
      $_ =~ m/=\s*(\w+)/;   
      $javaInitMem= $1."%";
    } else {
      # wrapper.java.initmemory=2048
      $_ =~ m/=\s*(\w+)/;   
      $javaInitMem= $1."mb";
    }  
  } elsif (/^wrapper.java.maxmemory/) {
    if (/\.percent/) {
      # wrapper.java.maxmemory.percent=40
      $_ =~ m/=\s*(\w+)/;   
      $javaMaxMem= $1."%";
    } else {
      # wrapper.java.maxmemory=4096
      $_ =~ m/=\s*(\w+)/;   
      $javaMaxMem= $1."mb";
    }  
  }
}
close(FILE);

my $str=sprintf("Init Java memory: %s\nMax Java memory: %s\n", $javaInitMem, $javaMaxMem);
printf($str);

InvokeCommander("SuppressLog", "setProperty", "summary", $str);

exit(0);

















