#
# Create a uniq directory
mkdir ("plugin.$[/myJob/jobId]");
chdir("plugin.$[/myJob/jobId]");

# Create the META-INF and pages directories
mkdir("META-INF");
mkdir ("pages");
mkdir ("cgi-bin");
mkdir ("htdocs");

# Open persmission the project export can be written
# in the case the server and agent run with 2 different users
chmod (0777, "META-INF");
