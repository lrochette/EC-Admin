$[/myProject/performances/scripts/perf.pm]
$DEBUG=1;

my $DBPropFile="$[/server/Electric Cloud/dataDirectory]/conf/database.properties";
my $DBType;
open FILE, "< $DBPropFile" || die "Cannot open the file $DBPropFile\n";
while (<FILE>) {
  if (/DB_TYPE/) {
    # Extract DB type
    # COMMANDER_DB_TYPE=mysql
    $_ =~ m/=(\w+)/;   
    $DBType = $1;
    last;
  }
}
close(FILE);

printf("Database: %s\n", $DBType);
if ($DBType eq "builtin") {
  printf("BAD\n");
  InvokeCommander("SuppressLog", "setProperty", "outcome", "warning");
} elsif ($DBType eq "mysql") {
  printf("GOOD\n");
} elsif (($DBType eq "sqlserver") || ($DBType eq "oracle")) {
  printf("BEST\n");
} else {
  printf ("Unknown\n");
  InvokeCommander("SuppressLog", "setProperty", "summary", "UNKNOWN");
  exit(1);
}  
InvokeCommander("SuppressLog", "setProperty", "summary", $DBType);

exit(0);






















