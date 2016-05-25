############################################################################
#
#  Copyright 2016 Electric-Cloud Inc.
#
#  Create the gradlew and gradlew.bat files based on some properties stored
#  in EC-Admin/gradle
#
#############################################################################

$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

my @propList= qw (gradlew gradlew.bat);

foreach my $prop (@propList) {
	my $value=getP("/myProject/gradle/$prop");

  open(my $fh, "> $prop");
  print $fh $value;
  close($fh);
	chmod(0755, $prop);
}

$[/myProject/scripts/perlLibJSON]

