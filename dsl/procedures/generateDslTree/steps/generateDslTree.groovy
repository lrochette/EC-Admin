#############################################################################
#
#  Copyright 2018 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

#
# Global variables
#
my $pName = "EC-Admin";
my $rootpath = "/Users/lrochette/SourceCode/lrochette";
my $path  = "dsl/procedures";

printf("Extracting Project: %s\n", $pName);
my $fileProjectName=safeFilename($pName);
mkpath("$root/$fileProjectName/$path");
chmod(0777, "$root/$fileProjectName/$path");

my ($success, $xPath) = InvokeCommander("SuppressLog", "getProcedures", $pName);
 foreach my $proc ($xPath->findnodes('//procedure')) {
   my $procName=$proc->{'procedureName'};
   my $fileProcedureName=safeFilename($procName);
   printf("  Extracting Procedure: %s\n", $procName);

   mkpath("$root/$fileProjectName/$path/$fileProcedureName");
   chmod(0777, "$root/$fileProjectName/$path/$fileProcedureName");
   `ectool generateDsl "/projects/$pName/procedures/$procName" > "$root/$fileProjectName/$path/$fileProcedureName/procedure.groovy"`;
   
