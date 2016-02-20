############################################################################
#
#  deleteWorkspaceDirectory: remove a workspace directory on a specific 
#                            machine to deal with local workspaces
#  Copyright 2015 Electric-Cloud Inc.
#
#############################################################################

use File::Path;
use File::stat;
use Fcntl ':mode';

# Perl Commander Header
$[/myProject/scripts/perlHeaderJSON]


#############################################################################
#
#  Assign Commander parameters to variables
#
#############################################################################
my $executeDeletion = "$[executeDeletion]";
my $computeUsage    = "$[computeUsage]";
my $winDir          = "$[winDir]";
my $linDir		    = "$[linDir]";

my $wksDir="";
if ($osIsWindows) {
	$wksDir =  "$winDir";
} else {
    $wksDir = "$linDir";
}

$[/myProject/scripts/deleteWorkspace]

# additional functions
$[/myProject/scripts/getDirSize]
$[/myProject/scripts/humanSize]













