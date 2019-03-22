<h1>EC-Admin</h1>

<p>EC-Admin is a collection of administrative procedures to help you
manage your server. Its inception was sparked by requests from customers
during my Professional Services engagements. It has grown over the years to what it is now.</p>

<p>In June 2018, the plugin was been converted to the
  <a href="https://github.com/electric-cloud/PluginWizard">PluginWizard DSL</a>
  format so the whole plugin code is now managed on GiyHub without the need to
  extract the project first.<br/>
As a side effect the promotion of the plugin can take a couple of minutes as
the DSL code as to be evaluated on the server.</p>

<p>Requirements:</p>
<ul>
  <li>Electric Flow 6.0 minimum</li>
  <li>EC-PluginManager 1.4.0</li>
</ul>

<h2><a name="installation"></a>Installation</h2>

<p>This collection of procedures can be found on our
<a href="https://github.com/electric-cloud-community/EC-Admin">GitHub
repository</a>. It is available as a plugin delivered
in the form of a .jar file or you can simply get the source code
and build it yourself.</p>

<p>To install the plugin, use one the following methods:</p>
<ul>
<li>the "Install from File/URL" tab in the administration/Plugins</li>
<li>the Perl "$ec->installPlugin()" API.</li>
<li> the CLI client "ectool installPlugin --force 1 EC-Admin.jar</li>
</ul>
<p>Don't forget to promote the plugin after installation. Now the plugin has
  been converted to PluginWizard and DSL format, the promotion takes a little
  longer. You have to increase to DSL timeout setting to at least 180 (3 minutes).</p>

<p>To install on 4.0.x or or 4.1.x, import the EC_4.0.xml file. Be
aware that some features are not present as the original project
makes use of createJobStep() API which was introduced in 4.2.0:<br/>
ectool import /path_to/EC-Admin_for_EC_4.0.xml --disableSchedules 1</p>

<h2><a name="building"></a>Building</h2>
<p>To build the plugin, you will need to have first to build
  <a href="https://github.com/electric-cloud/ecpluginbuilder">ecpluginbuilder</a>
  for your platform.<br/>

  Then simply:
  <ul>
    <li>log into your Flow server with "ectool --server SERVER login USER PWD"</li>
    <li>run "ec-perl ecpluginbuilder.pl", the tool will:
      <ul>
        <li>increment the build counter (main version can be changed in the script or with the -version option)</li>
        <li>build the plugin</li>
        <li>install the plugin</li>
        <li>promote the plugin</li>
      </ul>  
    </li>
    </ul>
</p>

<h1>Contact authors</h1>
<dl>
<dt>License Logger:</dt>
<dd>Mike Westerhof</dd>

<dt>deleteObjects:</dt>
<dt>testResources:</dt>
<dd><a href="https://github.com/tanaynagjee">Tanay Nagjee</a></dd>

<dt>Everything else:</dt>
<dd> <a href="mailto:lrochette@electric-cloud.com">Laurent Rochette</a></dd>
</dl>

<h1>Thanks</h1>
<p>Thanks to Mark Hall for providing the Dev and Prod logos for
  changeBannerColor.</p>
<p>Thanks to <a href="mailto:dhubbell@spkaa.com">David Hubbell</a> for his
constant flow of fixes to my poor code.</p>

<h1>Legal Mumbo Jumbo</h1>

<p>This plugin is free for use. Modify it however you see fit to better your
experience using ElectricFlow. Share
your <a href="https://github.com/electric-cloud-community/EC-DslDeploy/issues">enhancements</a>
and <a href="https://github.com/electric-cloud-community/EC-DslDeploy/pulls">fixes</a>.</p>

<p>This module is not officially supported by Electric Cloud. It has undergone no
formal testing and you may run into issues that have not been uncovered in the
limited testing done so far.</p>

<p>Electric Cloud should not be held liable for any repercussions of using this
software.</p>
