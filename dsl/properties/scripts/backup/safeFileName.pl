#
# Make the name of an object safe to be a file or directory name
#
sub safeFilename {
  my $safe=@_[0];
  $safe =~ s#[\*\.\"/\[\]\\:;,=\|\?<>]#_#g;
  $safe =~ s/^\s+//;     # remove heading spaces
  $safe =~ s/\s+$//;      # remove trailing spaces
  $safe =~ s/\x{2013}/-/g; # replace long MS dash by normal ones
  $safe =~ s/\x{fffd}/ /g; # replace black diamond question mark with space
  
  return $safe;
}
