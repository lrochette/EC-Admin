$[/myProject/scripts/perlHeaderJSON]
use File::Copy;

my $color=lc("$[color]");
my $colorCode=lc('$[colorCode]');
$color="#4d4d4d" if ($color eq "default");
$color=$colorCode if ($colorCode ne "");

my $cssFile= "$ENV{COMMANDER_HOME}/apache/htdocs/flow/public/app/assets/css/main.css";
copy($cssFile,"${cssFile}_$[/timestamp YYYY-MM-dd]") or die "Copy failed: $!";

open(my $FH, "< $cssFile") || die ("Cannot open $cssFile\n");
my @lines=<$FH>;
close($FH);

my @out=();
my $foundBlock =0;

my $line=$lines[0];
# Change background color
$line =~ s/\.context-header \.gh-background\{position:relative;height:50px;background-color:[^;]+;/.context-header .gh-background{position:relative;height:50px;background-color:$color;/;
# Change logo
$line =~ s!(\.context-header \.gh-background \.logo\{background-image:url)\(([^)])+\);background-repeat:no-repeat;width:\d+px;?!$1(../img/logo.png);background-repeat:no-repeat;width:225px;!;
push (@out, $line);
open(my $FH, "> $cssFile") || die ("Cannot open $cssFile\n");
print $FH @out;
close($FH);
