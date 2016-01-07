#############################################################################
#
#  modifyWrapper -- Script to change the memory setting of the Java agent.
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################
use File::Copy;

$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $initMemory = "$[initMemory]";
my $maxMemory  = "$[maxMemory]";

#############################################################################
#
#  Global variables
#
#############################################################################
my $wrapperFile= "$ENV{COMMANDER_DATA}/conf/agent/wrapper.conf";
my @out=();       # the modified set of lines
my $line;
my ($initMemPercentComment, $initMemPercentValue) = ('#', 15);
my ($initMemMbComment,      $initMemMbValue)      = ('#', 16);
my ($maxMemPercentComment,  $maxMemPercentValue)  = ('#', 15);
my ($maxMemMbComment,       $maxMemMbValue)       = ('#', 64);

#
# Check for correctness in the data
#
if ($initMemory =~ /^\s*(\d+)\s*(%?)\s*$/) {
  my ($value, $percent)=($1, ($2 eq '%')?1:0);
  printf("Init: %d, percent: %s\n", $value, $percent);
  if ($percent) {
    $initMemPercentComment='';
    $initMemPercentValue=$value;
  } else {
    $initMemMbComment='';
    $initMemMbValue=$value;
  }
} else {
  printf("Error: the init memory parameter should be a number followed optionally by %%: %s\n", $initMemory);
  exit(1);
}

if ($maxMemory =~ /^\s*(\d+)\s*(%?)\s*$/) {
  my ($value, $percent)=($1, ($2 eq '%')?1:0);
  printf("Max: %d, percent: %s\n", $value, $percent);
  if ($percent) {
    $maxMemPercentComment='';
    $maxMemPercentValue=$value;
  } else {
    $maxMemMbComment='';
    $maxMemMbValue=$value;
  }
} else {
  printf("Error: the max memory parameter should be a number followed optionally by %%: %s\n", $maxMemory);
  exit(1);
}
copy($wrapperFile,"${wrapperFile}_$[/timestamp YYYY-MM-dd]") or die "Copy failed: $!";

open(my $FH, "< $wrapperFile") || die ("Cannot open $wrapperFile\n");
my @lines=<$FH>;
close($FH);

while (defined($line=shift(@lines))) {
  # looking for specific line indiacating start of the block
  if ($line =~ /Specify java heap size in percentage OR mb/) {
    # now write the new block
    push (@out, $line);
    my $block=sprintf("
# Initial Java Heap Size (in %)
%swrapper.java.initmemory.percent=%d

# Initial Java Heap Size (in mb)
%swrapper.java.initmemory=%d

# Maximum Java Heap Size (in %)
%swrapper.java.maxmemory.percent=%d

# Maximum Java Heap Size (in mb)
%swrapper.java.maxmemory=%d

",
    $initMemPercentComment, $initMemPercentValue,
    $initMemMbComment,      $initMemMbValue,
    $maxMemPercentComment,  $maxMemPercentValue,
    $maxMemMbComment,       $maxMemMbValue,
    );
    push(@out, $block);

    # Now skip the rest of the block until we get to the comment line
    do {
      $line=shift(@lines);
    } while ($line !~ /#\*+/);
    push (@out, $line);
  } else {
        push (@out, $line);
    }
}

open(my $FH, "> $wrapperFile") || die ("Cannot open $wrapperFile\n");
print $FH @out;
close($FH);

