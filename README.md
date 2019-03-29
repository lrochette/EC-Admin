#EC-Admin

EC-Admin is a collection of advanced management, optimization, and customization
tools for ElectricFlow. It includes tools for:

* Bulk resource health checks
* White labeling
* Log management
* Advanced backup
* License statistics
* Debug tools
* More

</p>
<p>EC-Admin is used in many ElectricFlow field deployments.</p>
<p>In June 2018, the plugin was converted to the
  <a href="https://github.com/electric-cloud/PluginWizard">PluginWizard DSL</a>
  format so the whole plugin code is now managed on GitHub without the need
  to extract the project first.</p>

</p>The official stable version can be found in the plugins
  catalog or in
  our <a href="https://electric-cloud.com/plugins/directory/p/ec-admin">plugins
  directory</a>. You can also follow development
  in our <a href="https://github.com/electric-cloud-community/EC-Admin">Community
  GitHub repository</a>. For the latest code changes, check
  the <a href="https://github.com/lrochette/EC-Admin">maintainer's fork</a>.</p>

<p>Requirements:</p>
<ul>
  <li>Electric Flow 6.0 minimum
  <li>EC-PluginManager 1.4.0
</ul>

<h2><a name="installation"></a>Installation</h2>

<p> It is available as a plugin delivered in the form of
a .jar file.</p>

<p>To install the plugin, use one the following methods:</p>
<ul>
<li>ElecricFlow Administration/Plugins UI - "Install from File/URL"
<li>CLI - `ectool installPlugin --force 1 EC-Admin.jar`
<li>Perl - `$ec->installPlugin()" API`.
</ul>
<p>Don't forget to promote the plugin after installation.</p>

<p>To install on 4.0.x or or 4.1.x, import the EC_4.0.xml file. Be
aware that some features are not present as the original project
makes use of createJobStep() API which was introduced in 4.2.0:<br/>

```ectool import /path_to/EC-Admin_for_EC_4.0.xml --disableSchedules 1```

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
