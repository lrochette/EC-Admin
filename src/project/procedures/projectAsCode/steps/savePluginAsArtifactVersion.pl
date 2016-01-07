#############################################################################
#
#  uploadPlugins -- upload all plugins in the Artifact Repository
#  Copyright 2014 Electric-Cloud Inc.
#
#############################################################################

$[/myProject/scripts/perlHeader]

#
# Parameters
#
my $plugin="$[/myJob/pluginName]";
my $Version="$[/myJob/Version]";

#
# Is this plugin already imported in an Artifact Version
#
my ($ok)=InvokeCommander("SuppressLog IgnoreError", 'getArtifactVersion', "plugins:$plugin:$Version");
if ($ok) {
	printf("\tArtifact Version already exists\n");
    exit 1;    # Artifact already exist
}

#
# Does the Artifact already exist?
#
($ok)=InvokeCommander("SuppressLog IgnoreError", 'getArtifact', "plugins:$plugin");
if (! $ok) {
	InvokeCommander("SuppressLog", 'createArtifact',
		{
        	groupId=>"plugins", artifactKey=>$plugin
		}
);
}
InvokeCommander("SuppressLog", 'publishArtifactVersion',
		{
        	groupId=>"plugins", artifactKey=>$plugin,  version=>$Version,
        	fromDirectory=>".",
            includePatterns=>"*.jar"
		}
);

$[/myProject/scripts/perlLib]





