package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class artifactRepoSync extends PluginTestHelper {
  static String pName='EC-Admin'

  def doSetupSpec() {
  }

  def doCleanupSpec() {
  }

  // Check procedures exist
  def "checkProcedures for artifactRepoSync"() {
    given:
    when:
      def res1=dsl """
        getProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "artifactRepositorySynchronization"
        ) """

    then:
      assert res1?.procedure.procedureName == 'artifactRepositorySynchronization'
 }

  // incorrect source repo
  def "Incorrect source repo"() {
    given : "Incorrect source repository"
    when: "the procedure runs"
      def result=runProcedureDsl """
         runProcedure(
           projectName: "/plugins/$pName/project",
           procedureName: "artifactRepositorySynchronization",
           actualParameter: [
             sourceRepository: "DOESNOTEXIST",
             targetRepository: "default",
             batchSize: "10",
             syncResource: "local",
             artifactVersionPattern: "*"
           ]
         )"""

    then: "it should error out"
      assert result.outcome == "error"
  }

 // incorrect target repo
 def "Incorrect target repo"() {
   given : "Incorrect target repository"
   when: "the procedure runs"
     def result=runProcedureDsl """
        runProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "artifactRepositorySynchronization",
          actualParameter: [
            sourceRepository: "default",
            targetRepository: "DOESNOTEXIST",
            batchSize: "10",
            syncResource: "local",
            artifactVersionPattern: "*"
          ]
        )"""

   then: "it should error out"
     assert result.outcome == "error"
 }

 // ino artifact version to sync
 def "no artifact version to sync"() {
   given : "no artifact version to sync"
   when: "the procedure runs"
     def result=runProcedureDsl """
       runProcedure(
         projectName: "/plugins/$pName/project",
         procedureName: "artifactRepositorySynchronization",
         actualParameter: [
           sourceRepository: "default",
           targetRepository: "default",
           batchSize: "10",
           syncResource: "local",
           artifactVersionPattern: "DOESNOTEXIST"
         ]
       )"""

    then: "it should succeed"
      assert result.outcome == "success"
      def summary=getStepProperty(result.jobId, 'syncRepo', "summary")
      assert summary == "0 artifact versions"
  }

}
