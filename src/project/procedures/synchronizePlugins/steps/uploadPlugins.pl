#############################################################################
#
#  uploadPlugins -- upload all plugins in the Artifact Repository
#  Copyright 2014 Electric-Cloud Inc.
#
#############################################################################

$[/myProject/scripts/perlHeader]

#############################################################################
#
#  Global Variables
#
#############################################################################
my $nbPlugins=0;

my ($ok, $res)=InvokeCommander("SuppressLog", "getPlugins");
foreach my $node ($res->findnodes('//plugin') ){
	my $fullName=$node->findvalue('pluginName');
    my ($name, $version) = $fullName =~ m/([\w \-]+)-([\d\.]+)/;
    #my $version=$node->{pluginVersion};
    printf("Processing $name : $version\n");
    
	#
    # Is this plugin already imported in an Artifact Version
    #
	($ok)=InvokeCommander("SuppressLog IgnoreError", 'getArtifactVersion', "plugins:$name:$version");
    if ($ok) {
    	printf("\tAV already exist\n");
        next;    # Artifact already exist
    }
	#
    # Does the Artifact already exist?
    #
    ($ok)=InvokeCommander("SuppressLog IgnoreError", 'getArtifact', "plugins:$name");
    if (! $ok) {
    	InvokeCommander("SuppressLog", 'createArtifact',
    		{
            	groupId=>"plugins", artifactKey=>$name
    		}
    );
    }
    InvokeCommander("SuppressLog", 'publishArtifactVersion',
    		{
            	groupId=>"plugins", artifactKey=>$name,  version=>$version,
            	fromDirectory=>"$[/server/Electric Cloud/dataDirectory]/plugins/$name-$version"
    		}
    );
    $nbPlugins++;
}
$ec->setProperty("summary", "$nbPlugins plugins uploaded");

$[/myProject/scripts/perlLib]



















