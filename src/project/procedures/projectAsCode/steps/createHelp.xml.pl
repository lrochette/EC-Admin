$[/myProject/scripts/perlHeaderJSON]
$[/myProject/scripts/perlLibJSON]

my $file="pages/help.xml";
my $help=getP("/projects/$[Project]/help");
my $HELP;

if ($help ne "") {
  chdir("$[directory]");
  open($HELP, "> $file") || die("Cannot open help.xml");

  print $HELP "$help";
  close($HELP);
}
