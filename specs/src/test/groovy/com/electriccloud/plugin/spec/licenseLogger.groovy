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
    given:
    when:
      def res1=dsl """
        getProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "licenseLogger-snapshot"
        ) """
      def res2=dsl """
        getProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "licenseLogger-report"
        ) """

    then:
      assert res1?.procedure.procedureName == 'licenseLogger-snapshot'
      assert res2?.procedure.procedureName == 'licenseLogger-report'
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
         principalName: "everyone",
         propertySheetId: "$psId"
       ) """
    then:
      assert result.aclEntry.readPrivilege == "allow"
      assert result.aclEntry.modifyPrivilege == "allow"
  }
}
