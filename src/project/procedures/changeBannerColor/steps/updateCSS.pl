$[/myProject/scripts/perlHeaderJSON]
use File::Copy;
    
my $color=lc("$[color]");
$color="#000000" if ($color eq "default");

my $cssFile= "$ENV{COMMANDER_HOME}/apache/htdocs/commander/lib/styles/StdFrame.css";

# check that we are running version 6.x or later
my $version=getVersion();
printf("%s\n",$version);
if (compareVersion($version, "6.0") >= 0) {
  $cssFile= "$ENV{COMMANDER_HOME}/apache/htdocs/commander/styles/StdFrame.css"; 
}
copy($cssFile,"${cssFile}_$[/timestamp YYYY-MM-dd]") or die "Copy failed: $!";

open(my $FH, "< $cssFile") || die ("Cannot open $cssFile\n");
my @lines=<$FH>;
close($FH);

my @out=();
my $foundBlock =0;

foreach my $line (@lines) {
	if ($line =~ /\.frame_bannerTop/) {
    	push (@out, "/* modified by EC-Admin on $[/timestamp YYYY-MM-dd] */\n");
        push (@out, $line);
        $foundBlock = 1;
    } elsif ($foundBlock && ($line =~ /background-color/)) {
    	push(@out, "    background-color: $color;\n");
        $foundBlock = 0;
    } else {
        push (@out, $line);
    }
}

open(my $FH, "> $cssFile") || die ("Cannot open $cssFile\n");
print $FH @out;
close($FH);

$[/myProject/scripts/perlLibJSON]
















