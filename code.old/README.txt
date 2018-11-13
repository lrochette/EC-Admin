This directory is intended to archive old code that is not required anymore.

A side effect of using PluginWizard framework to create the plugin is that the
promotion "step" is longer than for a plugin created the "old way".
To help with that issue, I decided to move obsolete code to this directory.

So far I archived:
 - agentMemoryConfiguration: ecconfigure addresses that
 - createPluginFromProject: DSL and PluginWizard address that
 - findJobId: used to help customer migrate from 4.2
 - performanceMetrics: no science behind, not sure it was ever used
 - projectAsCode: DSL and PluginWizard address that

 Matching system tests have also been archived
