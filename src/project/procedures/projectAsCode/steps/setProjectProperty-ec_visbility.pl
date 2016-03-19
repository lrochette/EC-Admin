$[/myProject/scripts/perlHeaderJSON]

my $pName="$[Plugin]";
my $pCategory="$[Category]";
my $project="$[Project]";


if (! getP("/projects/$project/ec_visibility")) {
  $ec->setProperty("/projects/$[Project]/ec_visibility", "pickListOnly");
} else {
   $ec->setProperty("/myCall/ecVisibility",  getP("/projects/$project/ec_visibility") );
}

$[/myProject/scripts/perlLibJSON]



















