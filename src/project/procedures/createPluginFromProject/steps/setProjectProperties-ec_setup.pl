$[/myProject/scripts/perlHeader]

my $pName="$[Plugin]";
my $pCategory="$[Category]";
my $project="$[Project]";
my $moveJobs="$[moveJobs]";		# boolean to move old jobs to new version

if ($pName eq "") {
  $pName=$project;
}

my $ECsetup="";

#
# Add code to move the old jobs if checkbox is on
#
if ($moveJobs eq "true") {
	$ECsetup .= << 'MOVEJOBS' ;
# Move old jobs to new version
if ( $promoteAction eq 'promote' ) {
   if ($otherPluginName ne "") {
        $commander->moveJobs($otherPluginName, $pluginName);
    }
}
MOVEJOBS

}

#
# Pickup code for Promote/demote
#
if (getP("/projects/$project/promoteAction")) {
  $ECsetup .= "# promote/demote action\n";
  $ECsetup .= getP("/projects/$project/promoteAction");
  $ECsetup .= "\n\n";
}

$ECsetup .= "# Data that drives the create step picker registration for this plugin.\n";

# Loop on each procedure
my $proc;              # Loop variable
my $xpath;
my $pickerList="";

my @procList=$ec->getProcedures($project)->findnodes("//procedure");
foreach $xpath(@procList) {
   my $procName=$xpath->findvalue("//procedureName");
   
   #
   # Skip this procedure if property "exposeToPlugin" is not set to 1
   #
   next if (getP("/projects/$project/procedures/$procName/exposeToPlugin") != 1);
   
   #
   #
   # If property "descrirptionForPlugin" exists, use it
   # if not, use the procedure description itself
   #
   my $description=getP("/projects/$project/procedures/$procName/descriptionForPlugin");
   if (!$description) {
     $description=$xpath->findvalue("//description");
   }
   my $procCleanName=$procName;
   $procCleanName =~ s/[\s\-\.]/\_/g; # replace spaces, . and - by _

# Create a block of perl Code for each procedure ala
#my %startBuild = (
#    label => "$Jenkins- Start a build",
#    procedure => "startBuild",
#    description => "Start a build.",
#    category => "Other"
#);

#escape double quote in the description
  $description =~ s/"/\\"/g;
  
   $ECsetup .= "my %" . "$procCleanName = ( 
  label       => \"$pName - $procName\", 
  procedure   => \"$procName\", 
  description => \"$description\", 
  category    => \"$pCategory\" 
);

" ;

  $pickerList .= "\\%". $procCleanName . ", "; 
} # end foreach loop


# Create the picker List ala
#@::createStepPickerSteps = (\%startBuild, \%getStatus, \%getLog, \%getDuration);

#remote the trailing ", " from the picker List
chop($pickerList); chop($pickerList);
$ECsetup .= "\@::createStepPickerSteps = (" . $pickerList . ");\n";

print "Code generated\n";
print $ECsetup;
$ec->setProperty("//projects/$[Project]/ec_setup", $ECsetup);

$[/myProject/scripts/perlLib]








