package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class cleanup extends PluginTestHelper {
  static String pName='EC-Admin'

  def doSetupSpec() {
  }

  def doCleanupSpec() {
  }

  // Check procedures exist
  def "checkProcedures for cleanup"() {
    given: "a list of procedure"
      def list= ["jobsCleanup", "pipelinesCleanup", "artifactsCleanup",
        "artifactsCleanup_byQuantity", "cleanupCacheDirectory", "cleanupRepository",
        "deleteWorkspaceOrphans", "jobCleanup_byResult", "subJC_deleteWorkspace"]
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

}
