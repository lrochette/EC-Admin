EC-Admin
========

This project includes a few procedures to help you with disk management and other
administrative tasks of your ElectricCommander server.

jobsCleanup: procedure to delete jobs older than a specified number of
days. It will also delete associated workspace job directories. You
can also provide a property name, if this property is attached to the
job, it won't be deleted now matter how old. A report only mode
prevents any real deletion.

artifactsCleanup: procedure to delete artifacts older than a specified number
of days. Same as above, a property allows to prevent deletion. Once the
artifacts have been deleted, artifact repositories and artifact caches are
cleaned as well (deleting stale artifacts).  A report only mode prevents any
real deletion.

acquireSemaphore & releaseSemaphore: those 2 procedures are used to create a 
gate for a set of steps. The important part is to use a resource with a step 
limit of one to ensure the atomicty of increasing and decreasing the gate 
value.

saveProjects: a simple procdure to export individually all (non plugins) 
projects to create you own versioning. Better to run on a nightly schedule.

plugin creation: two different procedures help you transform your favorite project
into a plugin to make it easier to version and deploy to your production
server.

performanceMetrics: a procedure to gather a bunch of data about your Commander
environment and may help when things start to slow down.

changeBannerColor: A procedure to change the color of the banner to easily identify 
your multiple servers (DEV vs. PROD)

To install on 4.2.x and later, use the "Install from File/URL" tab in the 
administration/Plugins or use the "installPlugin" API.
	ectool  installPlugin EC-Admin.jar

to install on 4.0.x or 4.1.x, import the EC_4.0.xml file. Be aware that 
some features are not present as the original project makes use of 
createJobStep() API which was introduced in 4.2.0:

ectool import /path_to/EC-Admin_for_EC_4.0.xml --disableSchedules 1

If you get an error with the passKey, use the --force 1 option

Contact author: 
  Laurent Rochette (lrochette@electric-cloud.com) 

Legal Jumbo
 
This module is free for use. Modify it however you see fit to better your 
experience using ElectricCommander. Share your enhancements and fixes.

This module is not officially supported by Electric Cloud. It has undergone no 
formal testing and you may run into issues that have not been uncovered in the 
limited manual testing done so far.

Electric Cloud should not be held liable for any repercusions of using this 
software.
