$[/myProject/performances/scripts/perf.pm]

my $CPUspeed;     # Amount of RAM in GB
if ($OSNAME =~ /MSWin/) {
  my @result=`wmic cpu get MaxClockSpeed`; # result on 2nd line
  $CPUspeed = int($result[1])/1000;
} elsif ($OSNAME eq "linux") {
  $CPUspeed=`cat /proc/cpuinfo | grep "cpu MHz" | head -1 |awk '{print \$4}'`;
  chomp $CPUspeed;
  #printf("CPU speed: %s\n", $CPUspeed);
   $CPUspeed /= 1000;
}  else {
  printf ("OS: %s not supported for Commander server\n", $OSNAME); 
  exit(2);
}

my $str=sprintf("%2.1f GHz\n", $CPUspeed);
printf("CPU speed: $str\n");
checkValue("CPU", $CPUspeed, $str);




