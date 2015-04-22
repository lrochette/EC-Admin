$[/myProject/scripts/perlHeaderJSON]

my $color=lc("$[color]");
$color="#000000" if ($color eq "default");

my $cssFile= "$env{COMMANDER_HOME}/apache/htdocs/commander/lib/styles/StdFrame.css";

open(my FH, "< $cssFile") || die ("Cannot open $cssFile\n");
my @lines=<FH>;
close(FH);

my @out=();
my $foundBlock =0;

foreach my $line (@lines) {
	if ($line =~ /\.frame_bannerTop/) {
    	push (@out, "/* modified by EC-Admin on $[/timestamp YYYY-MM-dd]\n");
        push (@out, $line);
        $foundBlock =1;
    } else if ($line =~ /background-color/) {
    	push(@out, "    background-color: $color\n");
        $foundBlock =0;
    } else {
        push (@out, $line);
    }
}
