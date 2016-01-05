$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

#
# Global Variables
#
my ($ok, $json, $errMSg, $errCode);
my $proc="createConfiguration";
my $step="createAndAttachCredential";
my $version=getVersion();

if (compareVersion($version, "6.0")>=0) {
	($ok, $json, $errMSg, $errCode) =
    	InvokeCommander("IgnoreError", 'attachParameter', $project, "credential", 
        	{
            	procedureName=>$proc, 
                stepName=>$step
            } );
} else {
	($ok, $json, $errMSg, $errCode) =
		InvokeCommander("IgnoreError", 'attachParameter', $project, $proc, $step, "credential");
}
exit(0) if ($ok);

exit(1);

$[/myProject/scripts/perlLibJSON]



