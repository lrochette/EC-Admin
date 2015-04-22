$[/myProject/scripts/perlHeaderJSON]

###################################################################
#
# Parameters
#
###################################################################
my $subject = "$[subject]";
my $text = "$[text]";
my $html = "$[html]";
my $mailConfig = "$[config]";

###################################################################
#
# Global variables
#
###################################################################
my $MAX = 10000;
my @mailingList=();

my $json=$ec->getUsers({maximum => $MAX});
foreach my $user ($json->findnodes('//user')) {
	printf("Processing %s\n", $user->{userName}) if ($DEBUG);
	push (@mailingList, $user->{userName});
}

if ($html eq "true") {
	$cmdr->sendEmail({
    	configName => $mailCOnfig,
       	subject    => $subject,
        bcc        => \@mailingList,
        html       => $text,
   });
} else {
	$cmdr->sendEmail({
    	configName => $mailCOnfig,
       	subject    => $subject,
        bcc        => \@mailingList,
        text       => $text,
   });
}

