$[/myProject/performances/scripts/perf.pm]

#
# Param
#
$DEBUG=$[debugMode];

my $freeRAM=0;     # Amount of RAM in GB
if ($OSNAME =~ /MSWin/) {
  $freeRAM=`systeminfo | find "Available Physical Memory"`;
  chomp $freeRAM;
  printf("free RAM amount: %s\n", $freeRAM) if ($DEBUG);
  # Available Physical Memory: 4,948 MB   or 4,948 in Europe
  $freeRAM =~ s/Available Physical Memory:\s+([\d,.]+) MB/$1/m;
  $freeRAM =~ s/,//;
  printf("RAM amount: %d\n", $freeRAM) if ($DEBUG);
} elsif ($OSNAME eq "linux") {
  $freeRAM=`/usr/bin/free -m | grep "cache:" | awk '{print \$3}'`;
  chomp $freeRAM;
  printf("free RAM amount: %d\n", $freeRAM) if ($DEBUG);
  $freeRAM /= 1024
}  else {
  printf ("OS: %s not supported for Commander Server\n", $OSNAME);
  exit(2);
}

if ($freeRAM == 0) {
  printf ("Error getting the RAM amount on %s\n", $OSNAME);
  exit(2);
}

my $str=sprintf("%3.1f MB\n", $freeRAM);
printf("RAM amount: $str\n");
InvokeCommander("SuppressLog", "setProperty", "summary", $str);
