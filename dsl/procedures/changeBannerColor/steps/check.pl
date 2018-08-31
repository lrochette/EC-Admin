$[/myProject/scripts/perlHeaderJSON]

my $apacheDir= "$ENV{COMMANDER_HOME}/apache";

if (! -d $apacheDir) {
  printf("You are not on the webserver. Please rerun and change the web resource parameter");
  $ec->setProperty("summary", "Not a webserver");
  exit(1);
}
