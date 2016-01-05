$[/myProject/performances/scripts/perf.pm]

#
# Param
#
$DEBUG=$[debugMode];

my $freeDisk=0;     # Amount of available disk on the Data partition
my $diskPartition="$[/server/Electric Cloud/dataDirectory]";

if ($OSNAME =~ /MSWin/) {
  my $drive=substr($diskPartition,0,2);
  printf("Drive:'%s'\n", $drive);
  system('fsutil volume diskfree $drive 2>&1') if ($DEBUG);
  $freeDisk=`fsutil volume diskfree $drive 2>&1`; # | find "avail free"
  chomp $freeDisk;
  if ($freeDisk =~ /avail free/) {
    $freeDisk =~ m/avail free bytes\s+:\s*(\d+)/;
    printf("free Disk Space for %s: %s\n", $diskPartition, $freeDisk) if ($DEBUG);
    $freeDisk=humanSize($freeDisk); 
  } else {
    printf("Error:\n$freeDisk\n");
    InvokeCommander("SuppressLog", "setProperty", "summary", $freeDisk);
    exit(1);
  }
} elsif ($OSNAME eq "linux") {
  $freeDisk=`/bin/df -h $diskPartition | tail -1 | awk '{print \$4}'`;
  chomp $freeDisk;
  # Make the unit  as the other ones
  $freeDisk =~ s/G/ GB/;
  $freeDisk =~ s/M/ MB/;
  printf("free Disk Space for %s: %s\n", $diskPartition, $freeDisk) if ($DEBUG);
}  else {
  printf ("OS: %s not supported for Commander Server\n", $OSNAME); 
  exit(2);
}

printf("Disk space available: %s\n", $freeDisk);
InvokeCommander("SuppressLog", "setProperty", "summary", $freeDisk);





