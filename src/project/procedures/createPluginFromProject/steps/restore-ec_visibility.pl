$[/myProject/scripts/perlHeaderJSON]

my $pName="$[Plugin]";
my $pCategory="$[Category]";
my $project="$[Project]";

$ec->deleteProperty("/projects/$[Project]/ec_visibility");
if ( $[/javascript (typeof(myCall.ecVisibility) != "undefined") ?"1":"0" ] ) {
   printf("Restoring ec_visibility\n");
   $ec->setProperty("/projects/$[Project]/ec_visibility", getP("/myCall/ecVisibility") );
}
$[/myProject/scripts/perlLibJSON]














