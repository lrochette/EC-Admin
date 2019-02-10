#############################################################################
#
# Compare 2 version number strings like x.y.z... section by section
# return 1 if V1 > v2
# return 0 if v1 == v2
# return -1 if v1 < v2
#
#############################################################################
sub compareVersion {

  my ($v1, $v2)=@_;
  
  my @v1Numbers = split('\.', $v1);
  my @v2Numbers = split('\.', $v2);

  for (my $index = 0; $index < scalar(@v1Numbers); $index++) {
    
    # We ran out of V2 numbers => V1 is a bigger version
    return 1 if (scalar(@v2Numbers) == $index);

    # same value, go to next number
    next if ($v1Numbers[$index] == $v2Numbers[$index]);
        
    # V1 is a bigger version
    return 1 if ($v1Numbers[$index] > $v2Numbers[$index]);
           ;
    # V2 is a bigger version
    return -1;
  }

  # We ran out of V1 numbers
  return -1 if(scalar(@v1Numbers) != scalar(@v2Numbers));

  # Same number
  return 0;
}
