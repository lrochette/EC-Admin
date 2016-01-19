$[/myProject/performances/scripts/perf.pm]

#
# Parameters
#
my $nbSteps=$[numberOfSteps];

my $startTime = time();
for (my $i=1; $i <= $nbSteps; $i++) {
  $ec->createJobStep({'jobStepName' => "DBperf-$i",
                      'command'     => "echo Test $i Done"
                        }); 
}
my $totalTime=time()-$startTime;

printf("To run %d steps, it took %d sec\n", $nbSteps, $totalTime);
my $DBperf=$totalTime/$nbSteps;
my $str=sprintf("%.3f step/sec\n", $DBperf);
$ec->setProperty('/myJob/DBPerf', $DBperf);

printf("Database performance: $str\n");
checkValue("DBPERF", $DBperf, $str);











