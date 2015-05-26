$[/myProject/scripts/perlHeaderJSON]

#
# Param
#
my $project="$[Project]";

my $proc="createConfiguration";
my $step="createAndAttachCredential";

my ($ok, $json, $errMSg, $errCode)
	= InvokeCommander("IgnoreError", 'attachParameter', $project, $proc, $step, "credential");
exit(0) if ($ok);

exit(1);

$[/myProject/scripts/perlLibJSON]

