<h1>EC-Admin</h1>

<p>EC-Admin is a collection of administrative procedures to help you
manage your server. Its inception was sparked by requests from customers
during my Professional Services engagements. It has grown over the years to
what it is now.</p>

<p>It contains the following modules:</p>
<ul>
<li><a href="#look">Look and Feel</a></li>
<li><a href="#jobs">Jobs and Workspaces management</a></li>
<li><a href="#plugin">Plugins</a></li>
<li><a href="#artifacts">Artifacts management</a></li>
<li><a href="#backup">Object export and backup</a></li>
<li><a href="#semaphore">Semaphore management</a></li>
<li><a href="#perf">Performance metrics</a></li>
<li><a href="#license">License Logger</a></li>
<li><a href="#postp">postp debugger helper</a></li>
</ul>

<h2><a name="installation"></a>Installation</h2>
		
<p>It is available as a plugin delivered in the form of a .jar file or you can simply get the source code and recompile it yourself.</p>

<p>To install the plugin, use the "Install from File/URL" tab in the administration/Plugins or use the "installPlugin" API.</p>

<p>To install on 4.0.x or or 4.1.x, import the EC_4.0.xml file. Be 
			aware that some features are not present as the original project 
			makes use of createJobStep() API which was introduced in 4.2.0:<br/>
ectool import /path_to/EC-Admin_for_EC_4.0.xml --disableSchedules 1</p>

<p>If you get an error with the passKey, use the "--force 1" option</p>

<p>IMPORTANT: For more details, consult the Help page after you have installed the plugin.</p>

<h1><a name="look"></a>Look and Feel</h1>
<h2>changeBannerColor</h2>
<p>If you work on multiple Commander servers like a development and a 
			production instances, this procedure is for you. It allows you to change 
			the color of the top banner and the logo to make it easier to identify your different 
			servers. Feel free 
			to <a href="mailto:lrochette@electric-cloud.com">send me</a> new ones if 
			you have a more artistic touch than me. Or better
			push your changes to 
<a href="https://github.com/electriccommunity/EC-Admin">GitHub</a>.</p>

<h1><a name="jobs"></a>Jobs and Workspaces management</h1>
<p>This set of procedures will help you manage your old jobs and the 
			associated workspaces.</p>

<h2>jobsCleanup:</h2> 
<p>A procedure to delete jobs older than a specified number of
days. It will also delete associated workspace job directories.</p>

<h2>jobCleanup_byResult:</h2> 
<p>A procedure to delete jobs older than a specified number of days.
It will also delete associated workspace job directories. It will keep the
number of successful, failed and warning jobs you entered. You can also
provide a property name, if this property is attached to the job, it won't be
deleted no matter how old. A report only mode prevents any real deletion.</p>

<h2>deleteWorksapceOrphans:</h2> 

<p>A procedure to crawl a workspace directory to find orphan jobs
(directories without a matching job) on a specified resource.</p>

<h2>deleteObjects:</h2> 
<p>A procedure to quickly delete jobs or workflows older than a
specified number of days. It will <b>not</b> delete associated workspace job
directories. This is for customers with huge job or workflow database.</p>


<h1><a name="plugin"></a>Plugins</h1>
<h2>Plugin Synchronization</h2>
<p>This procedure synchronizes plugins between the server and 
		a resource. Plugins are uploaded first as artifacts if it has not been 
		done already and then downloaded on the resource if it does not 
		already exist in the plugins directory.</p>
		
<h2>Plugin creation</h2>
<h3>createPluginFromProject</h3>
<p><b>Note:</b> This procedure requires access to the jar or zip 
			executable in the PATH.</p>
<p>The procedure "createPluginFromProject" allows the transformation of a project into a plugin.</p>

<h3>projectAsCode</h3>

<p><b>Note:</b> This procedure requires access to a resource with the Commander SDK installed.</p>

<p>This procedure is an extension of createPluginFromProject. It also
		creates a plugin but instead of simply exporting the project, it
		"explodes" each step in its own file for finer granularity check in
		in your favorite SCM tool.</p>


<p><b>Note:</b> EC-Admin is released on 
<a href="https://github.com/electriccommunity/EC-Admin">GitHub</a> using 
		this procedure.</p>

<h1><a name="artifacts"></a>Artifact Management</h1>

<h2>artifactRepositorySynchronization</h2>

<p>Synchronize the content of remote artifact repositories to a local
resource. You can use pattern matching to select specific artifact
versions to synchronize.</p>

<h2>artifactsCleanup</h2> 
		
<p>A procedure to delete artifact versions older than a specified number
of days. Same as for jobs above, a property allows preventing the deletion. Once the
artifacts have been deleted, artifact repositories and artifact caches are
cleaned as well (deleting stale artifacts).  A report mode prevents any
real deletion.</p>

<h2>artifactsCleanup_byQuantity</h2>

<p>As "ArtifactsCleanup"", this procedure deletes artifact versions 
			older than a specified number
of days but keeps only X per Artifact. Again, a property allows preventing the 
deletion. Once the
artifacts have been deleted, artifact repositories and artifact caches are
cleaned as well (deleting stale artifacts).  A report only mode prevents any
real deletion.</p>

<h1><a name="backup"></a>Object export and backup</h1>

<p>This set of procedures is to help you export objects from
ElectricCommander for a potential inclusion into your SCM for
versioning.</p>
		
<h2>saveProjects</h2>

<p>This procedure simply exports your projects in a directory on the
server. It is recommended to enable the nightly schedule associated
with it to backup your projects on a regular basis.</p>

<h2>saveAllObjects</h2>

<p>This procedure brings a finer granularity to a full server export.
For  example, it may be easier to retrieve a simple project or procedure
instead of the full server export or database backup to undo r a wrong action
or a bad code change. By  default it exports projects and each procedure
individually. In addition by  enabling the matching checkboxes, you can also
export resources,  resource pools, workspaces, users and groups, and with 5.x
and later ElectricFlow Deploy objects (Applications, Components and
Environments). It is recommended to enable the nightly schedule associated
with it to backup your projects on a regular basis.</p>

<p><b>Note:</b> Use saveProjects or saveAllObjects depending on the
		granularity you are requiring.</p>

<h1><a name="semaphore"></a>Semaphore Management</h1>

<h2>acquireSemaphore and releaseSemaphore:</h2>
			
<p>Those 2 procedures are used to create a 
gate for a set of steps. The important part is to use a resource with a step 
limit of one to ensure the atomicity of increasing and decreasing the gate 
value.</p>

<h1><a name="perf"></a>Performance metrics</h1>
<p>This procedure returns some information about your 
			ElectricCommander server like number of processors, total RAM, 
			available RAM, 
ping times with agents, relative performance of agents, ... 
In addition it checks the amount of time spent running steps on the server 
local agents as this should be minimized as much as possible.</p>

<h1><a name="license"></a>License Logger</h1>
<p>The License Logger mechanism is intended to collect and email various
license-related statistics. It is implemented as a set of schedules and procedures,
along with a set of configuration properties.</p>

<h1><a name="postp"></a>postp debugger helper</h1>
<p>The debugPostp is a simple procedure to help you debug with postp. Traditionally you would call postp from the command line with the jobStepId of the faulty postp and adding some additional option to see details. This new procedure does that for you on Linux and Windows, you just have to pass the jobStepId as a parameter.</p>

<h1>Contact authors</h1> 
<dl>
<dt>License Logger</dt>
<dd>Mike Westerhof (<a href="mailto:mwesterhof@electric-cloud.com">mwesterhof@electric-cloud.com</a>)</dd>
  <dt>Other</dt>
  <dd>Laurent Rochette (<a href="mailto:lrochette@electric-cloud.com">lrochette@electric-cloud.com</a>)</dd>
</dl>

<h1>Legal Jumbo</h1>
 
<p>This module is free for use. Modify it however you see fit to better your 
experience using ElectricCommander. Share your enhancements and fixes.</p>

<p>This module is not officially supported by Electric Cloud. It has undergone no 
formal testing and you may run into issues that have not been uncovered in the 
limited manual testing done so far.</p>

<p>Electric Cloud should not be held liable for any repercussions of using this 
software.</p>
</div>
</body>
</html>
