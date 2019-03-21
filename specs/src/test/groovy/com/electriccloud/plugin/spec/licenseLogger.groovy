package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class licenseLogger extends PluginTestHelper {
  static String pName='EC-Admin'

  def doSetupSpec() {
  }

  def doCleanupSpec() {
  }

  // Check procedures exist
  def "checkProcedures for licenseLogger"() {
    given: "a list of procedure"
      def list= ["licenseLogger-snapshot", "licenseLogger-report"]
      def res=[:]
    when: "check for existence"
      list.each { proc ->
        res[proc]= dsl """
          getProcedure(
            projectName: "/plugins/$pName/project",
            procedureName: "$proc"
          ) """
      }
    then: "they exist"
      list.each  {proc ->
        println "Checking $proc"
        assert res[proc].procedure.procedureName == proc
      }
 }

  // Issue 52
  // EC-Admin counter is writable
  def "issue 52"() {
    given:
    when:
      def ps = dsl """getProperty(propertyName: "/server/counters/$pName")"""
      def psId = ps.property.propertySheetId
      def result = dsl """
       getAclEntry(
         principalType: 'group',
         principalName: "Everyone",
         propertySheetId: "$psId"
       ) """
    then:
      assert result.aclEntry.readPrivilege == "allow"
      assert result.aclEntry.modifyPrivilege == "allow"
  }
}
