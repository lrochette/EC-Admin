package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class backup extends PluginTestHelper {
  static String pName='EC-Admin'
  static String backupDir="/tmp"

  def doSetupSpec() {
    dslFile 'dsl/EC-Admin_Test.groovy'
    // new AntBuilder().delete(dir:"$backupDir" )
    // {
    //   fileset( dir:"data/restore" )
    // }

  }

  def doCleanupSpec() {
  }

  def runSaveAllObjects(String jobName, def additionnalParams) {
    println "Running runSaveAllObjects"
    def params=[
        pathname: "$backupDir",
        pattern: "",
        exportDeploy: "false",
        exportGateways: "false",
        exportZones: "false",
        exportGroups: "false",
        exportResourcePools: "false",
        exportResources: "false",
        exportSteps: "false",
        exportUsers: "false",
        exportWorkspaces: "false",
        format: "XML",
        pool: "default"
    ]
    assert jobName

    additionnalParams.each {k, v ->
      params[k]="$v"
    }
    def res=runProcedureDslAndRename(
      jobName,
      """runProcedure(
            projectName: "/plugins/$pName/project",
            procedureName: "saveAllObjects",
            actualParameter: $params
         )
      """
    )
    return res
  }

  // Check procedures exist
  def "checkProcedures for backup feature"() {
    given: "a plugin"
    when: "promoted"
      def res1=dsl """
        getProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "saveAllObjects"
        ) """
      def res2=dsl """
        getProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "saveProjects"
        ) """

    then: "procedures should be present"
      assert res1?.procedure.procedureName == 'saveAllObjects'
      assert res2?.procedure.procedureName == 'saveProjects'
 }

  // Issue 56: question mark
  def "issue 56 - question mark"() {
    given: "a project with a question mark"
    when: "save objects in XML format"
      def result=runSaveAllObjects("Issue56", [pattern: "EC-Admin_Test"])
    then: "question mark replaced by _"
      assert result.jobId
      assert result?.outcome == 'success'

      def file=new File("$backupDir/projects/EC-Admin_Test/procedures/questionMark/steps/rerun_.xml")
      assert file.exists()
  }
}
