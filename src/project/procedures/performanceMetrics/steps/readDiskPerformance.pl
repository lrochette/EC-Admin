use IO::Handle;
$[/myProject/performances/scripts/perf.pm]

#
# Parameters
my $nbGBs=$[numberOfGB];

# the file was created by the previous step
my $filename = "output.txt";

open FILE, "< $filename"
    or die "could not open $filename: $!";
binmode FILE;

my $startTime = time();
my ($data, $n);
# Let's read the file by 1K
while (($n = read(FILE, $data, 1024)) != 0) {}
close FILE;

my $totalTime=time()-$startTime;
close FILE;
unlink ($filename);

printf("To read %d GB, it took %d sec\n", $nbGBs, $totalTime); 
my $READspeed=$nbGBs * 1024 / $totalTime;
$ec->setProperty("/myJob/readDiskPerf", $READspeed);
my $str=sprintf("%5.1f MB/s\n", $READspeed);
printf("Disk Read speed: $str\n");
checkValue("DISKREAD", $READspeed, $str);














