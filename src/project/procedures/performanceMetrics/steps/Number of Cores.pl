$[/myProject/performances/scripts/perf.pm]

my $nbCores;     # Number of cores
if ($OSNAME =~ /MSWin/) {
  $nbCores=$ENV{NUMBER_OF_PROCESSORS};
} elsif ($OSNAME eq "linux") {
  $nbCores=`nproc`;
  chomp $nbCores;
}  else {
  printf ("OS: %s not supported for COmmander server\n", $OSNAME); 
  exit(2);
}

my $str=sprintf("%2d cores\n", $nbCores);
printf("Number of cores: $str\n");
checkValue("CORE", $nbCores, $str);


