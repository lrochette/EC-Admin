package com.electriccloud.plugin.spec
import spock.lang.*
//import com.electriccloud.spec.PluginSpockTestSupport

class ECAdmin extends PluginTestHelper {
  static String pName='EC-Admin'
  @Shared String pluginName

  def doSetupSpec() {
    dsl """
      resource 'ecadmin-lin',
        hostName: 'localhost',
        hostType: 'REGISTERED'
    """
    dslFile "dsl/${pName}_Test.groovy"
    this.pluginName=getP("/plugins/$pName/project/projectName")
  }

  def doCleanupSpec() {
    conditionallyDeleteProject('${pName}_Test')
    dsl """deleteResource(resourceName: 'ecadmin-lin')"""
  }

  // Check promotion
  def "plugin promotion"() {
    given:
    when: 'the plugin is promoted'
      def result = dsl """promotePlugin(pluginName: "$pName")"""
      def version = dsl """getProperty("/plugins/$pName/pluginVersion")"""
      def prop = dsl """getProperty("/plugins/$pName/project/ec_visibility")"""
    then:
      assert result.plugin.pluginVersion == version.property.value
      // assert prop.property.value == 'pickListOnly'
    }

  // Check properties /plugins/$pName/projects/scripts work properly
  def "scripts_perlCommonLib"() {
    given:
    when:
      def result=runProcedureDsl """runProcedure(projectName: "${pName}_Test", procedureName: "scriptsPropertiesTest") """
    then:
      assert result.outcome == 'success'
      assert getStepProperty(result.jobId, "humanSize", "result") == "3.00 MB"
      assert getStepProperty(result.jobId, "humanSize", "exitCode") == "0"
  }

  def "getPS"() {
    given:
    when:
      def result=runProcedureDsl """runProcedure(projectName: "${pName}_Test", procedureName: "getPS") """
    then:
      assert result.outcome == 'success'
      assert getStepProperty(result.jobId, "getPSJSON", "exitCode") == "0"
      assert getStepProperty(result.jobId, "getPSXML", "exitCode") == "0"
  }

  def "ACL_on_server"() {
     given:
      def pluginName=this.pluginName
     when:
       def ps = dsl """getProperty(propertyName: "/server/$pName")"""
       def psId = ps.property.propertySheetId
       def result = dsl """
        getAclEntry(
          principalType: 'user',
          principalName: "project: $pluginName",
          projectName: "/plugins/$pName/project",
          propertySheetId: "$psId") """
    then:
      assert result
  }

  def "timeout_config_property"() {
    given:
    when:
      def timeout=getP("/server/$pName/cleanup/config/timeout")
    then:
      assert timeout == "600"
  }

  def "cleanpOldJobs_config_property"() {
    given:
    when:
      def timeout=getP("/server/$pName/licenseLogger/config/cleanpOldJobs")
    then:
      assert timeout == "1"
  }

  def "workspace_config_property"() {
    given:
    when:
      def timeout=getP("/server/$pName/licenseLogger/config/workspace")
    then:
      assert timeout == "default"
  }

  def "emailConfig_config_property"() {
    given:
    when:
      def timeout=getP("/server/$pName/licenseLogger/config/emailConfig")
    then:
      assert timeout == "default"
  }

  def "resource_config_property"() {
    given:
    when:
      def timeout=getP("/server/$pName/licenseLogger/config/resource")
    then:
      assert timeout == "local"
  }

  def "Naming convention"() {
    given:
    when:
      def procedures = dsl """
        getProcedures(
          projectName: "/plugins/$pName/project"
        )"""
     then:
       procedures.procedure.each { proc ->
         assert ! proc.procedureName.contains("/?icopy/")
         assert ! proc.procedureName.contains("/ /")
       }
  }


}
