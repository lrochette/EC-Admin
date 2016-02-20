my $filename = "output.txt";

if (-f $filename) {
  unlink($filename);
  printf("Deleting %s\n", $filename);
}














