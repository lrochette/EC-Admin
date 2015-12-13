@files = (
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="licenseLogger"]/propertySheet/property[propertyName="jobCleanup.pl"]/value', "properties/scripts/licenseLogger/jobCleanup.pl.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="compareVersion"]/value', "properties/scripts/compareVersion.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="deleteWorkspace"]/value', "properties/scripts/deleteWorkspace.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="getDirSize"]/value', "properties/scripts/getDirSize.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="getP"]/value', "properties/scripts/getP.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="humanSize"]/value', "properties/scripts/humanSize.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="jobTemplate"]/value', "properties/scripts/jobTemplate.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="perlCommonLib"]/value', "properties/scripts/perlCommonLib.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="perlHeader"]/value', "properties/scripts/perlHeader.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="perlHeaderJSON"]/value', "properties/scripts/perlHeaderJSON.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="perlLib"]/value', "properties/scripts/perlLib.txt"],
	['//project/propertySheet/property[propertyName="scripts"]/propertySheet/property[propertyName="perlLibJSON"]/value', "properties/scripts/perlLibJSON.txt"],
	['//project/propertySheet/property[propertyName="ec_setup"]/value', 'ec_setup.pl'],
	['//project/procedure[procedureName="acquireSemaphore"]/step[stepName="acquireSemaphore"]/command', 'procedures/acquireSemaphore/steps/acquireSemaphore.pl'],
	['//project/procedure[procedureName="artifactRepositorySynchronization"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/artifactRepositorySynchronization/form.xml'],
	['//project/procedure[procedureName="artifactRepositorySynchronization"]/step[stepName="syncRepo"]/command', 'procedures/artifactRepositorySynchronization/steps/syncRepo.pl'],
	['//project/procedure[procedureName="artifactsCleanup"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/artifactsCleanup/form.xml'],
	['//project/procedure[procedureName="artifactsCleanup"]/step[stepName="deleteArtifactVersions"]/command', 'procedures/artifactsCleanup/steps/deleteArtifactVersions.pl'],
	['//project/procedure[procedureName="artifactsCleanup"]/step[stepName="dynamicCleanRepoProcedure"]/command', 'procedures/artifactsCleanup/steps/dynamicCleanRepoProcedure.pl'],
	['//project/procedure[procedureName="artifactsCleanup"]/step[stepName="dynamicCacheCleaningProcedure"]/command', 'procedures/artifactsCleanup/steps/dynamicCacheCleaningProcedure.pl'],
	['//project/procedure[procedureName="artifactsCleanup_byQuantity"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/artifactsCleanup_byQuantity/form.xml'],
	['//project/procedure[procedureName="artifactsCleanup_byQuantity"]/step[stepName="deleteAV"]/command', 'procedures/artifactsCleanup_byQuantity/steps/deleteAV.pl'],
	['//project/procedure[procedureName="artifactsCleanup_byQuantity"]/step[stepName="dynamicCleanRepoProcedure"]/command', 'procedures/artifactsCleanup_byQuantity/steps/dynamicCleanRepoProcedure.pl'],
	['//project/procedure[procedureName="artifactsCleanup_byQuantity"]/step[stepName="dynamicCacheCleaningProcedure"]/command', 'procedures/artifactsCleanup_byQuantity/steps/dynamicCacheCleaningProcedure.pl'],
	['//project/procedure[procedureName="changeBannerColor"]/step[stepName="getVersion"]/command', 'procedures/changeBannerColor/steps/getVersion.pl'],
	['//project/procedure[procedureName="changeBannerColor"]/step[stepName="copyBannerFile"]/command', 'procedures/changeBannerColor/steps/copyBannerFile.sh'],
	['//project/procedure[procedureName="changeBannerColor"]/step[stepName="updateCSS"]/command', 'procedures/changeBannerColor/steps/updateCSS.pl'],
	['//project/procedure[procedureName="changeBannerColor"]/step[stepName="copyLogoFile"]/command', 'procedures/changeBannerColor/steps/copyLogoFile.sh'],
	['//project/procedure[procedureName="cleanupCacheDirectory"]/step[stepName="clearInvalidArtifactVersions"]/command', 'procedures/cleanupCacheDirectory/steps/clearInvalidArtifactVersions.pl'],
	['//project/procedure[procedureName="cleanupCacheDirectory"]/step[stepName="traverseCacheDirectory"]/command', 'procedures/cleanupCacheDirectory/steps/traverseCacheDirectory.pl'],
	['//project/procedure[procedureName="cleanupCacheDirectory"]/step[stepName="timeBaseDeletion"]/command', 'procedures/cleanupCacheDirectory/steps/timeBaseDeletion.pl'],
	['//project/procedure[procedureName="cleanupRepository"]/step[stepName="clearInvalidArtifactVersions"]/command', 'procedures/cleanupRepository/steps/clearInvalidArtifactVersions.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/createPluginFromProject/form.xml'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="Initialization"]/command', 'procedures/createPluginFromProject/steps/Initialization.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="createFileStructure"]/command', 'procedures/createPluginFromProject/steps/createFileStructure.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="fixSelfReferences"]/command', 'procedures/createPluginFromProject/steps/fixSelfReferences.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="createPlugin.xml"]/command', 'procedures/createPluginFromProject/steps/createPlugin.xml.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="setProjectProperty-ec_visbility"]/command', 'procedures/createPluginFromProject/steps/setProjectProperty-ec_visbility.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="setProjectProperties-ec_setup"]/command', 'procedures/createPluginFromProject/steps/setProjectProperties-ec_setup.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="createProject.xml"]/command', 'procedures/createPluginFromProject/steps/createProject.xml.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="restore-ec_visibility"]/command', 'procedures/createPluginFromProject/steps/restore-ec_visibility.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="createHelp.xml"]/command', 'procedures/createPluginFromProject/steps/createHelp.xml.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="packagePlugin"]/command', 'procedures/createPluginFromProject/steps/packagePlugin.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="savePluginAsArtifactVersion"]/command', 'procedures/createPluginFromProject/steps/savePluginAsArtifactVersion.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="installPlugin"]/command', 'procedures/createPluginFromProject/steps/installPlugin.pl'],
	['//project/procedure[procedureName="createPluginFromProject"]/step[stepName="promotePlugin"]/command', 'procedures/createPluginFromProject/steps/promotePlugin.pl'],
	['//project/procedure[procedureName="debugPostp"]/step[stepName="getJobStepInformation"]/command', 'procedures/debugPostp/steps/getJobStepInformation.pl'],
	['//project/procedure[procedureName="debugPostp"]/step[stepName="rerunPostp"]/command', 'procedures/debugPostp/steps/rerunPostp.pl'],
	['//project/procedure[procedureName="deleteObjects"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/deleteObjects/form.xml'],
	['//project/procedure[procedureName="deleteObjects"]/step[stepName="Delete"]/command', 'procedures/deleteObjects/steps/Delete.pl'],
	['//project/procedure[procedureName="deleteWorkspaceOrphans"]/step[stepName="crawlWorkspace"]/command', 'procedures/deleteWorkspaceOrphans/steps/crawlWorkspace.pl'],
	['//project/procedure[procedureName="jobCleanup_byResult"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/jobCleanup_byResult/form.xml'],
	['//project/procedure[procedureName="jobCleanup_byResult"]/step[stepName="deleteJobs.byProject"]/command', 'procedures/jobCleanup_byResult/steps/deleteJobs.byProject.pl'],
	['//project/procedure[procedureName="jobsCleanup"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/jobsCleanup/form.xml'],
	['//project/procedure[procedureName="jobsCleanup"]/step[stepName="deleteJobs"]/command', 'procedures/jobsCleanup/steps/deleteJobs.pl'],
	['//project/procedure[procedureName="licenseLogger-report"]/step[stepName="summarizeLicenseUsage"]/command', 'procedures/licenseLogger-report/steps/summarizeLicenseUsage.pl'],
	['//project/procedure[procedureName="licenseLogger-report"]/step[stepName="cleanup"]/command', 'procedures/licenseLogger-report/steps/cleanup.pl'],
	['//project/procedure[procedureName="licenseLogger-snapshot"]/step[stepName="getLicenseUsage"]/command', 'procedures/licenseLogger-snapshot/steps/getLicenseUsage.pl'],
	['//project/procedure[procedureName="licenseLogger-snapshot"]/step[stepName="cleanup"]/command', 'procedures/licenseLogger-snapshot/steps/cleanup.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Server RAM Amount"]/command', 'procedures/performanceMetrics/steps/Server RAM Amount.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Free RAM"]/command', 'procedures/performanceMetrics/steps/Free RAM.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Disk Space Available"]/command', 'procedures/performanceMetrics/steps/Disk Space Available.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Java Heap"]/command', 'procedures/performanceMetrics/steps/Java Heap.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Number of Cores"]/command', 'procedures/performanceMetrics/steps/Number of Cores.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Server CPU Speed"]/command', 'procedures/performanceMetrics/steps/Server CPU Speed.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="License Usage"]/command', 'procedures/performanceMetrics/steps/License Usage.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Database Type"]/command', 'procedures/performanceMetrics/steps/Database Type.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="deploymentSize"]/command', 'procedures/performanceMetrics/steps/deploymentSize.sh'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Write Disk Performance"]/command', 'procedures/performanceMetrics/steps/Write Disk Performance.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Read Disk Performance "]/command', 'procedures/performanceMetrics/steps/Read Disk Performance .pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="localUsage"]/command', 'procedures/performanceMetrics/steps/localUsage.sh'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Performance"]/command', 'procedures/performanceMetrics/steps/Performance.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Database Performance"]/command', 'procedures/performanceMetrics/steps/Database Performance.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="PingTime"]/command', 'procedures/performanceMetrics/steps/PingTime.pl'],
	['//project/procedure[procedureName="performanceMetrics"]/step[stepName="Clean Disk Performance Temporary File"]/command', 'procedures/performanceMetrics/steps/Clean Disk Performance Temporary File.pl'],
	['//project/procedure[procedureName="projectAsCode"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/projectAsCode/form.xml'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="Initialization"]/command', 'procedures/projectAsCode/steps/Initialization.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="setProjectProperty-ec_visbility"]/command', 'procedures/projectAsCode/steps/setProjectProperty-ec_visbility.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="createConfigurationCode"]/command', 'procedures/projectAsCode/steps/createConfigurationCode.sh'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="fixSelfReferences"]/command', 'procedures/projectAsCode/steps/fixSelfReferences.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="exportProjectToServer"]/command', 'procedures/projectAsCode/steps/exportProjectToServer.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="copyProjectToResource"]/command', 'procedures/projectAsCode/steps/copyProjectToResource.sh'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="deleteExportedProject"]/command', 'procedures/projectAsCode/steps/deleteExportedProject.sh'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="explodeProject"]/command', 'procedures/projectAsCode/steps/explodeProject.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="createFileStructure"]/command', 'procedures/projectAsCode/steps/createFileStructure.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="create_ec_setup.pl"]/command', 'procedures/projectAsCode/steps/create_ec_setup.pl.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="create_build.xml"]/command', 'procedures/projectAsCode/steps/create_build.xml.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="create_CHANGELOG"]/command', 'procedures/projectAsCode/steps/create_CHANGELOG.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="create_plugin.xml"]/command', 'procedures/projectAsCode/steps/create_plugin.xml.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="restore-ec_visibility"]/command', 'procedures/projectAsCode/steps/restore-ec_visibility.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="createHelp.xml"]/command', 'procedures/projectAsCode/steps/createHelp.xml.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="createConfigure.xml"]/command', 'procedures/projectAsCode/steps/createConfigure.xml.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="create_cgi-bin_configuration_files"]/command', 'procedures/projectAsCode/steps/create_cgi-bin_configuration_files.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="create_java_code"]/command', 'procedures/projectAsCode/steps/create_java_code.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="create_ConfigurationManagement.gwt.xml"]/command', 'procedures/projectAsCode/steps/create_ConfigurationManagement.gwt.xml.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="buildPlugin"]/command', 'procedures/projectAsCode/steps/buildPlugin.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="savePluginAsArtifactVersion"]/command', 'procedures/projectAsCode/steps/savePluginAsArtifactVersion.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="installPlugin"]/command', 'procedures/projectAsCode/steps/installPlugin.pl'],
	['//project/procedure[procedureName="projectAsCode"]/step[stepName="promotePlugin"]/command', 'procedures/projectAsCode/steps/promotePlugin.pl'],
	['//project/procedure[procedureName="releaseSemaphore"]/step[stepName="decrementSemaphore"]/command', 'procedures/releaseSemaphore/steps/decrementSemaphore.pl'],
	['//project/procedure[procedureName="removeParameterFromCall"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/removeParameterFromCall/form.xml'],
	['//project/procedure[procedureName="removeParameterFromCall"]/step[stepName="searchAndRemove"]/command', 'procedures/removeParameterFromCall/steps/searchAndRemove.pl'],
	['//project/procedure[procedureName="saveAllObjects"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/saveAllObjects/form.xml'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="grabResource"]/command', 'procedures/saveAllObjects/steps/grabResource.sh'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="saveProjectsProceduresWorkflows"]/command', 'procedures/saveAllObjects/steps/saveProjectsProceduresWorkflows.pl'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="saveResources"]/command', 'procedures/saveAllObjects/steps/saveResources.pl'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="saveResourcePools"]/command', 'procedures/saveAllObjects/steps/saveResourcePools.pl'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="saveWorkspaces"]/command', 'procedures/saveAllObjects/steps/saveWorkspaces.pl'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="saveUsers"]/command', 'procedures/saveAllObjects/steps/saveUsers.pl'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="saveGroups"]/command', 'procedures/saveAllObjects/steps/saveGroups.pl'],
	['//project/procedure[procedureName="saveAllObjects"]/step[stepName="saveDeployObjects"]/command', 'procedures/saveAllObjects/steps/saveDeployObjects.pl'],
	['//project/procedure[procedureName="saveProjects"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/saveProjects/form.xml'],
	['//project/procedure[procedureName="saveProjects"]/step[stepName="save Projects"]/command', 'procedures/saveProjects/steps/save Projects.pl'],
	['//project/procedure[procedureName="schedulesDisable"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/schedulesDisable/form.xml'],
	['//project/procedure[procedureName="schedulesDisable"]/step[stepName="disableSchedules"]/command', 'procedures/schedulesDisable/steps/disableSchedules.pl'],
	['//project/procedure[procedureName="schedulesEnable"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/schedulesEnable/form.xml'],
	['//project/procedure[procedureName="schedulesEnable"]/step[stepName="enableSchedules"]/command', 'procedures/schedulesEnable/steps/enableSchedules.pl'],
	['//project/procedure[procedureName="sendAlert"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/sendAlert/form.xml'],
	['//project/procedure[procedureName="sendAlert"]/step[stepName="sendAlert"]/command', 'procedures/sendAlert/steps/sendAlert.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="create _ui_forms"]/command', 'procedures/sub-pac_createConfigurationCode/steps/create _ui_forms.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="create _promoteAction"]/command', 'procedures/sub-pac_createConfigurationCode/steps/create _promoteAction.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="create _createConfiguration_procedure"]/command', 'procedures/sub-pac_createConfigurationCode/steps/create _createConfiguration_procedure.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="create _createConfiguration_CreateConfiguration_step"]/command', 'procedures/sub-pac_createConfigurationCode/steps/create _createConfiguration_CreateConfiguration_step.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="create _createConfiguration_createAndAttachCredential"]/command', 'procedures/sub-pac_createConfigurationCode/steps/create _createConfiguration_createAndAttachCredential.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="attach_parameter_credential"]/command', 'procedures/sub-pac_createConfigurationCode/steps/attach_parameter_credential.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="create _DeleteConfiguration_procedure"]/command', 'procedures/sub-pac_createConfigurationCode/steps/create _DeleteConfiguration_procedure.pl'],
	['//project/procedure[procedureName="sub-pac_createConfigurationCode"]/step[stepName="create _DeleteConfiguration_DeleteConfiguration_step copy"]/command', 'procedures/sub-pac_createConfigurationCode/steps/create _DeleteConfiguration_DeleteConfiguration_step copy.pl'],
	['//project/procedure[procedureName="subJC_deleteWorkspace"]/step[stepName="deleteWorkspaceDirectory"]/command', 'procedures/subJC_deleteWorkspace/steps/deleteWorkspaceDirectory.pl'],
	['//project/procedure[procedureName="subPM-deploymentSize"]/step[stepName="agents"]/command', 'procedures/subPM-deploymentSize/steps/agents.pl'],
	['//project/procedure[procedureName="subPM-deploymentSize"]/step[stepName="managedResources"]/command', 'procedures/subPM-deploymentSize/steps/managedResources.pl'],
	['//project/procedure[procedureName="subPM-deploymentSize"]/step[stepName="projects"]/command', 'procedures/subPM-deploymentSize/steps/projects.pl'],
	['//project/procedure[procedureName="subPM-deploymentSize"]/step[stepName="jobsPerDay"]/command', 'procedures/subPM-deploymentSize/steps/jobsPerDay.pl'],
	['//project/procedure[procedureName="subPM-deploymentSize"]/step[stepName="jobStepsPerDay"]/command', 'procedures/subPM-deploymentSize/steps/jobStepsPerDay.pl'],
	['//project/procedure[procedureName="subPM-jobStats"]/step[stepName="localUsage"]/command', 'procedures/subPM-jobStats/steps/localUsage.pl'],
	['//project/procedure[procedureName="subPM-localUsage"]/step[stepName="localUsage"]/command', 'procedures/subPM-localUsage/steps/localUsage.pl'],
	['//project/procedure[procedureName="subPM-performance"]/step[stepName="performance"]/command', 'procedures/subPM-performance/steps/performance.pl'],
	['//project/procedure[procedureName="subPM-ping"]/step[stepName="ping"]/command', 'procedures/subPM-ping/steps/ping.pl'],
	['//project/procedure[procedureName="synchronizePlugins"]/step[stepName="uploadPlugins"]/command', 'procedures/synchronizePlugins/steps/uploadPlugins.pl'],
	['//project/procedure[procedureName="synchronizePlugins"]/step[stepName="downloadPlugins"]/command', 'procedures/synchronizePlugins/steps/downloadPlugins.pl'],
	['//project/procedure[procedureName="workflowCleanup"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'procedures/workflowCleanup/form.xml'],
	['//project/procedure[procedureName="workflowCleanup"]/step[stepName="deleteWorkflows"]/command', 'procedures/workflowCleanup/steps/deleteWorkflows.pl'],
);
