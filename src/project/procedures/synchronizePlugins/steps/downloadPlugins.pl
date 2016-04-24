#############################################################################
#
#  downloadPlugins -- Script to parse all plugins from the artifact
#      repository and retrieve the latest version in the plugin directory if
#      it's not already there
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

my ($ok, $res)=InvokeCommander("SuppressLog", "findObjects", 'artifact', 
	{ filter=> [
					{propertyName => 'groupId', operator=>"equals", operand1=>"plugins"}
               ]
    });
foreach my $node ($res->findnodes('//artifact')) {
	my $artName=$node->findvalue('artifactKey');
    printf("Processing $artName\n");
    
	#
    # What is the latest Version of this Artfact/plugin
    #
	my ($ok, $avRes)=InvokeCommander("SuppressLog", 'findArtifactVersions', 
    			{artifactName=>"plugins:$artName"}
            );
    my $version=$avRes->findvalue('//version');
    my $AVN=$avRes->findvalue('//artifactVersionName');
    printf("\tRetrieved $version\n");
    
    if (-d "$[/server/Electric Cloud/dataDirectory]/plugins/$artName-$version") {
    	printf("\tplugins already exists\n");
        next;    # Plugin already exists
    } else {
	#
    # Retrieve the plugin
    #
    	$ec->retrieveArtifactVersions(
    		{
            	artifactVersionName => $AVN,
            	toDirectory => "$[/server/Electric Cloud/dataDirectory]/plugins/$artName-$version",
                overwrite => 'true'
    		}
    	);
        printf("\tDownloaded\n");
        $nbPlugins++;
    }
}
$ec->setProperty("summary", "$nbPlugins plugins downloaded");

$[/myProject/scripts/perlLib]





















