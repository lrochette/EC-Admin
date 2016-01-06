$[/myProject/scripts/perlHeaderJSON]

my $project="$[Project]";

$ec->deleteProperty("/projects/$project/ec_visibility");
if ( $[/javascript (typeof(myCall.ecVisibility) != "undefined") ?"1":"0" ] ) {
   printf("Restoring ec_visibility\n");
   $ec->setProperty("/projects/$project/ec_visibility", getP("/myCall/ecVisibility") );
}
$[/myProject/scripts/perlLibJSON]




