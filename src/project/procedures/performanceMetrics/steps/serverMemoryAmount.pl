$[/myProject/performances/scripts/perf.pm]

#
# Param
#
$DEBUG=$[debugMode];

my $RAM=0;     # Amount of RAM in GB
if ($OSNAME =~ /MSWin/) {
  $RAM=`wmic OS get TotalVisibleMemorySize /Value`;
  chomp $RAM;
  $RAM =~ s/TotalVisibleMemorySize=(\d+)/$1/m;
  $RAM = int($RAM);
  printf("RAM amount: %d\n", $RAM) if ($DEBUG);
  $RAM /= 1048576;  
} elsif ($OSNAME eq "linux") {
  $RAM=`cat /proc/meminfo | grep MemTotal | awk '{print \$2}'`;
  chomp $RAM;
  printf("RAM amount: %d\n", $RAM) if ($DEBUG);
   $RAM /= 1048576;
}  else {
  printf ("OS: %s not supported for Commander Server\n", $OSNAME); 
  exit(2);
}

#
# 
#
if ($RAM == 0) {
  printf ("Error getting the RAM amount on %s\n", $OSNAME);
  exit(2);
}

my $str=sprintf("%3.1f GB\n", $RAM);
printf("RAM amount: $str\n");
checkValue("RAM", $RAM, $str);









