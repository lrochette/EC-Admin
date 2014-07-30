$[/myProject/scripts/perlHeaderJSON]

my $file="pages/help.xml";
my $help=getP("/projects/$[Project]/help");
my $HELP;

#
# Working directory is $[directory]
if ($help ne "") {
  printf("Create help.xml from the project help property\n");
  open($HELP, "> $file") || die("Cannot open help.xml");

  print $HELP "$help";
  close($HELP);
} else {
  if (! -f "$file") {
    printf("Create a dummy skeleton help.xml\n");

    open($HELP, "> $file") || die("Cannot open help.xml");
    $help= '	
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta content="text/html; charset=us-ascii" http-equiv="content-type" />

    <title>Electric Commander Plugin for $[/myJob/pluginName]</title>
    <link rel="stylesheet" href= "../../plugins/@' . 'PLUGIN_KEY' . '@/pluginhelp.css" type="text/css" media= "screen" />
</head>

<body>
    <div class="help">
    <h1>Jenkins</h1>
    <p>Plugin Version @' . 'PLUGIN_VERSION' . '@</p>
    <hr style="margin-left: -10px; margin-top: 10px; height: 1px; width: 100%; color: #5981BD;" noshade="noshade" />

    <p></p>
</body>
</html>
';
    print $HELP "$help";
    close($HELP);
  
    # Copy the pluginhelp.css from EC-Admin plugin on the server to the local directory
    $ec->createJobStep( { 
  	  subproject      => "/plugins/EC-FileOps/project",
      subprocedure    => "Remote Copy - Native",
      jobStepName     => "copy_pluginhelp.css", 
      actualParameter => [
    	{actualParameterName => 'sourceFile',               value => '$[/server/Electric Cloud/dataDirectory]/plugins/EC-Admin-$[/plugins/EC-Admin/pluginVersion]/htdocs/pluginhelp.css'},
    	{actualParameterName => 'sourceResourceName',       value => 'local'},
    	{actualParameterName => 'sourceWorkspaceName',      value => 'default'},
    	{actualParameterName => 'destinationFile',          value => '$[directory]/htdocs/pluginhelp.css'},
    	{actualParameterName => 'destinationResourceName',  value => '$[SDKResource]'},
    	{actualParameterName => 'destinationWorkspaceName', value => 'default'},
      ],
    });
  } else {
      printf("help.xml already exists. No new file created!\n");

  }
}

$[/myProject/scripts/perlLibJSON]

