$[/myProject/performances/scripts/perf.pm]

my $nbCores;     # Number of cores
if ($OSNAME =~ /MSWin/) {
  $nbCores=$ENV{NUMBER_OF_PROCESSORS};
} elsif ($OSNAME eq "linux") {
  #$nbCores=`nproc`;    # nproc seems limited to Ubuntu and Debian
  $nbCores=`cat /proc/cpuinfo | grep processor | wc -l`;
  chomp $nbCores;
}  else {
  printf ("OS: %s not supported for COmmander server\n", $OSNAME); 
  exit(2);
}

my $str=sprintf("%2d cores\n", $nbCores);
printf("Number of cores: $str\n");
$ec->setProperty("/myJob/numberOfCores", $nbCores);
checkValue("CORE", $nbCores, $str);









