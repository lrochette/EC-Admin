use IO::Handle;
$[/myProject/performances/scripts/perf.pm]

#
# Parameters
my $nbGBs=$[numberOfGB];
my $filename = "output.txt";

open my $numbers_outfile, ">", $filename
    or die "could not open $filename: $!";

$numbers_outfile->autoflush(1);

my $startTime = time();
#each time through the loop should be 1 gig
for (1 .. $nbGBs) {
    #each time though the loop should be 1 meg
    for (1 .. 1024) {
        #print 1 meg of Zs
        print {$numbers_outfile} "Z" x (1024*1024)
    }
}
my $totalTime=time()-$startTime;
close $numbers_outfile;

# Let's keep the file around for the read performance
#unlink ($filename);

printf("To write %d GB, it took %d sec\n", $nbGBs, $totalTime);

my$WRITEspeed=$nbGBs * 1024 / $totalTime;
$ec->setProperty("/myJob/writeDiskPerf", $WRITEspeed);
my $str=sprintf("%5.1f MB/s\n", $WRITEspeed);
printf("Disk Write speed: $str\n");
checkValue("DISKWRITE", $WRITEspeed, $str);








