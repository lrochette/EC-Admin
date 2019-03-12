package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class restore extends PluginTestHelper {
  static String zone="zone64"
  static String pName='EC-Admin'

  def doSetupSpec() {
    dsl """deleteZone(zoneName: "$zone")"""
    new AntBuilder().copy( todir:"/tmp/$zone" ) {
      fileset( dir:"data/restore" )
    }
  }

  def doCleanupSpec() {
    dsl """deleteZone(zoneName: "$zone")"""
  }

  // Issue 64
  def "issue 64"() {
    given:
    when:
      def result=runProcedureDsl """
        runProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "restoreObjects",
          actualParameter: [
            directory: "/tmp/$zone/",
            force: "false",
            resource: "local"
          ]
        )"""
      def z=dsl """
        getZone(zoneName: "$zone")
      """
    then:
      assert result.jobId
      assert result?.outcome == 'success'
      assert z.zone.zoneName == zone
  }
}
