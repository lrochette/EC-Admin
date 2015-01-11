if ($computeUsage eq "true") {
  my $wksSize = getDirSize($wksDir);
  printf ("    Size:\t%s\n", humanSize($wksSize));
  $ec->incrementProperty("/myJob/totalDiskSpace", $wksSize);
}
if ($executeDeletion eq "true") {
   rmtree ($wksDir)  ;
   print "    Deleting Directory $wksDir\n";
}

