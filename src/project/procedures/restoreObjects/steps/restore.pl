#############################################################################
#
#  restore -- Script to restore exported objects from .xml files
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################

# Perl Commander Header
$[/myProject/scripts/perlHeaderJSON]

#
# Parameters
#
my $directory='$[directory]';
my $force='$[force]';
my $resource='$[resource]';

#
# Global variables
#
my $forceOption="";

$forceOption="--force 1" if ($force eq "true");
chdir($directory) || die "Cannot change to $directory: $!";

# Loop over each .xml in the directory
opendir(D,".") || return 0;
foreach my $file (grep(/\.xml$/,readdir(D))) {
  $ec->createJobStep({
    jobStepName => $file,
    command =>"ectool import --file $directory/$file $forceOption"
  })
}
closedir(D);





