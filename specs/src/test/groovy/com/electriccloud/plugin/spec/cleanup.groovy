package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class cleanup extends PluginTestHelper {
  static String pName='EC-Admin'

  def doSetupSpec() {
    dsl """ project "pipe5" """
  }

  def doCleanupSpec() {
    dsl """deleteProject(projectName: "pipe5")"""
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

  // Issue 5
/*
  def "issue5 - delete Completed pipeline"() {
    given: "an old completed pipeline"
      // dslFile "dsl/cleanup/pipe5_completed_1.groovy"
      importXML("data/cleanup/pipe5_completed_1.xml")
    when:
      def res=runProcedureDsl("""
        runProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "pipelinesCleanup",
          actualParameter: [
            olderThan: "360",
            completed: "true",
            pipelineProperty: "",
            patternMatching: "",
            chunkSize: "5",
            executeDeletion: "1"
          ]
        )"""
      )
    then: " 1 pipeline was deleted"
      assert getJobProperty("nbFlowRuntimes", red.jobId) == "1"
  }
*/

}
