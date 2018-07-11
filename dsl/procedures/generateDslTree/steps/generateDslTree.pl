#############################################################################
#
#  Copyright 2018 Electric-Cloud Inc.
#
#############################################################################
use File::Path;

$[/myProject/scripts/perlHeaderJSON]

$DEBUG=1;
#
# Global variables
#
my $pName = "$[pName]";
# my $root = "/Users/lrochette/SourceCode/lrochette";
my $root = "$[root]";
my $path  = "dsl/procedures";

#
# Make the name of an object safe to be a file or directory name
#
sub safeFilename {
  my $safe=@_[0];
  $safe =~ s#[\*\.\"/\[\]\\:;,=\|\?<>]#_#g;
  $safe =~ s/^\s+//; # remove heading spaces
  $safe =~ s/\s+$//; # remove trailing spaces
  $safe =~ s/\x{2013}/-/g; # replace long MS dash by normal ones
  $safe =~ s/\x{fffd}/ /g; # replace black diamond question mark with space

  return $safe;
}

############################################################################
#
# Invoke a API call
#
#############################################################################
sub InvokeCommander {

    my $optionFlags = shift;
    my $commanderFunction = shift;
    my $result;
    my $success = 1;
    my $errMsg;
    my $errCode;

    my $bSuppressLog = $optionFlags =~ /SuppressLog/i;
    my $bSuppressResult = $bSuppressLog || $optionFlags =~ /SuppressResult/i;
    my $bIgnoreError = $optionFlags =~ /IgnoreError/i;

    # Run the command
    # print "Request to Commander: $commanderFunction\n" unless ($bSuppressLog);

    $ec->abortOnError(0) if $bIgnoreError;
    $result = $ec->$commanderFunction(@_);
    $ec->abortOnError(1) if $bIgnoreError;

    # Check for error return
    if (defined ($result->{responses}->[0]->{error})) {
        $errCode=$result->{responses}->[0]->{error}->{code};
        $errMsg=$result->{responses}->[0]->{error}->{message};
    }

    if ($errMsg ne "") {
        $success = 0;
    }
    if ($result) {
        print "Return data from Commander:\n" .
               Dumper($result) . "\n"
            unless $bSuppressResult;
    }

    # Return the result
    return ($success, $result, $errMsg, $errCode);
}

#############################################################################
#
# Return property value or undef in case of error (non existing)
#
#############################################################################
sub getP
{
  my $prop=shift;
  my $expand=shift;

  my($success, $xPath, $errMsg, $errCode)= InvokeCommander("SuppressLog IgnoreError", "getProperty", $prop);

  return undef if ($success != 1);
  my $val= $xPath->findvalue("//value");
  return $val;
}

#
# main
#
printf("Extracting Project: %s\n", $pName);
my $fileProjectName=safeFilename($pName);
mkpath("$root/$fileProjectName/$path");
chmod(0777, "$root/$fileProjectName/$path");

my ($success, $xPath) = InvokeCommander("SuppressLog", "getProcedures", $pName);
foreach my $proc ($xPath->findnodes('//procedure')) {
   my $procName=$proc->{'procedureName'};
   my $fileProcedureName=safeFilename($procName);
   printf("  Extracting Procedure: %s\n", $procName);

   mkpath("$root/$fileProjectName/$path/$fileProcedureName");
   chmod(0777, "$root/$fileProjectName/$path/$fileProcedureName");
   `ectool generateDsl "/projects/$pName/procedures/$procName" > "$root/$fileProjectName/$path/$fileProcedureName/procedure.groovy"`;

   # save steps
   mkpath("$root/$fileProjectName/$path/$fileProcedureName/steps");
   chmod(0777, "$root/$fileProjectName/$path/$fileProcedureName/steps");

   my($success, $stepNodes) = InvokeCommander("SuppressLog", "getSteps", $pName, $procName);
   foreach my $step ($stepNodes->findnodes('//step')) {
     my $stepName=$step->{'stepName'};
     my $fileStepName=safeFilename($stepName);
     printf("    Extracting Step: %s\n", $stepName);
     my $shell=$step->{'shell'};
     my $cmd=$step->{'command'};

     #
     # Save the Command
     #
     if ($cmd) {
       my $file;
       if ($shell eq "ec-perl") {
         $file="$root/$fileProjectName/$path/$fileProcedureName/steps/$fileStepName.pl"
       } else {
         $file="$root/$fileProjectName/$path/$fileProcedureName/steps/$fileStepName.sh"
       }
       open(my $fh, '>', $file) or die "Couldn't open file $file: $!";
       print $fh $cmd;
       close $fh;
     }
     #
     # Save the ec_paramaterForm if it exists
     #
     my $form=getP("/projects/$pName/procedures/$procName/ec_parameterForm");
     if ($form) {
       my $file="$root/$fileProjectName/$path/$fileProcedureName/form.xml";
       open(my $fh, '>', $file) or die "Couldn't open file $file: $!";
       print $fh $form;
       close $fh;
     }
   }  # step Loop
 }    # procedure Loop

$[/myProject/scripts/backup/safeFilename]

$[/myProject/scripts/perlLibJSON]
