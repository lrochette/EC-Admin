#
# export the DSL file
sub saveDslFile {
  my $path    = @_[0];
  my $obj     = @_[1];
  my $withAcl = @_[2];


  my $ret=system("ectool generateDsl \"$obj\" --withAcls $withAcl > \"$path\"");
  if ($ret == 0) {
# my ($success, $res, $errMsg, $errCode)
    return (1, "", "", "");
  } else {
    return (0, "", "", "");
  }
}
