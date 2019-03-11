package com.electriccloud.plugin.spec
import spock.lang.*
//import com.electriccloud.spec.PluginSpockTestSupport

class ECAdmin extends PluginTestHelper {

  def doSetupSpec() {
    dsl """resource 'ecadmin-lin', hostName: 'localhost' """
    dslFile 'dsl/EC-Admin_Test.groovy'
    //dsl "pingResource(resourceName: 'ecadmin-lin')"
  }

  def doCleanupSpec() {
    conditionallyDeleteProject('EC-Admin_Test')
    dsl """deleteResource(resourceName: 'ecadmin-lin')"""
  }

  // Check promotion
  def "plugin promotion"() {
    given:
      def pName='EC-Admin'
    when: 'the plugin is promoted'
      def result = dsl """promotePlugin(pluginName: "$pName")"""
      def version = dsl """getProperty("/plugins/$pName/pluginVersion")"""
      def prop = dsl """getProperty("/plugins/$pName/project/ec_visibility")"""
    then:
      assert result.plugin.pluginVersion == version.property.value
      assert prop.property.value == 'pickListOnly'
    }

  // Check properties /plugins/EC-Admin/projects/scripts work properly
  def "scripts_perlCommonLib"() {
    given:
    when:
      def result=runProcedureDsl """runProcedure(projectName: "EC-Admin_Test", procedureName: "scriptsPropertiesTest") """
    then:
      assert result.outcome == 'success'
      assert getStepProperty(result.jobId, "humanSize", "result") == "3.00 MB"
      assert getStepProperty(result.jobId, "humanSize", "exitCode") == "0"
  }

  def "getPS"() {
    given:
    when:
      def result=runProcedureDsl """runProcedure(projectName: "EC-Admin_Test", procedureName: "getPS") """
    then:
      assert result.outcome == 'success'
      assert getStepProperty(result.jobId, "getPSJSON", "exitCode") == "0"
      assert getStepProperty(result.jobId, "getPSXML", "exitCode") == "0"
  }

  def "ACL_on_server"() {
     given:
     when:
      def ps = dsl """getProperty(propertyName: "/server/EC-Admin")"""
      println "ps: " + ps
      def psId = ps.property.propertySheetId
      println "PsId:" + psId
      def result = dsl """
        getAclEntry(
          principalType: 'user',
          principalName: "project: /plugins/EC-Admin/project"),
          projectName: "/plugins/EC-Admin/project",
          propertySheetId: "$psId") """
    then:
      println "ACL result: " + result
      assert result
  }

  def "timeout_config_property"() {
    given:
    when:
      def timeout=getP("/server/EC-Admin/cleanup/config/timeout")
    then:
      assert timeout == "600"
  }

  def "cleanpOldJobs_config_property"() {
    given:
    when:
      def timeout=getP("/server/EC-Admin/licenseLogger/config/cleanpOldJobs")
    then:
      assert timeout == "1"
  }

  def "workspace_config_property"() {
    given:
    when:
      def timeout=getP("/server/EC-Admin/licenseLogger/config/workspace")
    then:
      assert timeout == "default"
  }

  def "emailConfig_config_property"() {
    given:
    when:
      def timeout=getP("/server/EC-Admin/licenseLogger/config/emailConfig")
    then:
      assert timeout == "default"
  }

  def "resource_config_property"() {
    given:
    when:
      def timeout=getP("/server/EC-Admin/licenseLogger/config/resource")
    then:
      assert timeout == "local"
  }

  def "Naming convention"() {
    given:
    when:
      def result = dsl """
        getProcedures(
          projectName: "/plugins/EC-Admin/project"
        )"""
     then:
       println "Naming convention"
       result.each {
         println "Procedure: " + it.procedureName
         assert ! it.procedureName.contains("/?icopy/")
         assert ! it.procedureName.contains("/ /")
       }
  }


}
