#############################################################################
#
# Calculate the size of the workspace directory
#
#############################################################################
sub getDirSize {
  my $dir = shift;
  my $size = 0;

  opendir(D,"$dir") || return 0;
  foreach my $dirContent (grep(!/^\.\.?/,readdir(D))) {
     my $st=stat("$dir/$dirContent");
     if (S_ISREG($st->mode)) {
       $size += $st->size;
     } elsif (S_ISDIR($st->mode)) {
       $size += getDirSize("$dir/$dirContent");
     }
  }
  closedir(D);
  return $size;
}
