$[/myProject/scripts/perlHeaderJSON]

###################################################################
#
# Parameters
#
###################################################################
my $subject = "$[subject]";
my $text = q($[text]);
my $mailConfig = "$[config]";

###################################################################
#
# Global variables
#
###################################################################
my $MAX = 10000;
my @mailingList=();
my %emailList=();

my $json=$ec->getUsers({maximum => $MAX});
foreach my $user ($json->findnodes('//user')) {
  my $userName = $user->{userName};
  my $email = $user->{email};
	printf("Processing %s: \t%s\n", $userName, $email) if ($DEBUG);

  # check for presence of @ in the email (cover also empty email)
  if (($email =~ /\@/) && (! exists($emailList{$email}))) {
    printf("\tadd") if ($DEBUG);
    $emailList{$email}=1;
    push (@mailingList, $user->{userName});
  }
}

print "\n\n" . Dumper(@mailingList) if ($DEBUG);

$ec->sendEmail({
      configName => $mailConfig,
      subject    => $subject,
      bcc        => \@mailingList,
      html       => "$text",
});









