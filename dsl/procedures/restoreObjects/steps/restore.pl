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
my $recursive='$[recursive]';
#
# Global variables
#
my $forceOption="";
my $counter=0;

$forceOption="--force 1" if ($force eq "true");
processDirectory($directory);
$ec->setProperty("summary", "Restored $counter files");
$ec->setProperty("/myJob/restoredFiles", "$counter");

sub processDirectory {
  my $directory=shift @_;

  chdir($directory) || die "Cannot change to $directory: $!";
  if (! opendir(D, $directory)) {
    warn "Cannot open $directory";
    return 0;
  }
  # loop over directory content and
  #    if directory and recursive, process
  #    import .xml files
  foreach my $file (readdir(D)) {
    next if $file eq ".";
    next if $file eq "..";
    if ( ($recursive eq "true") && (-d "$directory/$file")) {
      processDirectory("$directory/$file");
    } elsif ($file =~ /.xml$/) {

      $ec->createJobStep({
        jobStepName => "$directory/$file",
        command =>"ectool import --file \"$directory/$file\" $forceOption"
      });
      $counter++;
    }
  }
  closedir(D);
}
