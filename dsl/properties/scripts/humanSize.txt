#############################################################################
#
# Return human readable size
#
#############################################################################
sub humanSize {
  my $size = shift();

  if ($size > 1099511627776) { # TB: 1024 GB
      return sprintf("%.2f TB", $size / 1099511627776);
  }
  if ($size > 1073741824) { # GB: 1024 MB
      return sprintf("%.2f GB", $size / 1073741824);
  }
  if ($size > 1048576) { # MB: 1024 KB
      return sprintf("%.2f MB", $size / 1048576);
  }
  elsif ($size > 1024) { # KiB: 1024 B
      return sprintf("%.2f KB", $size / 1024);
  }
                                  # bytes
  return "$size byte" . ($size <= 1 ? "" : "s");
}
