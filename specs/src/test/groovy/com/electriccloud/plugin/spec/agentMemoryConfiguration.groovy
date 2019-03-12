package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class agentMemoryConfiguration extends PluginTestHelper {
  static String pName='EC-Admin'

  def doSetupSpec() {
  }

  def doCleanupSpec() {
  }

  // Check procedures exist
  def "checkProcedures for agentMemoryConfiguration"() {
    given:
    when:
      def res1=dsl """
        getProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "agentMemoryConfiguration"
        ) """

    then:
      assert res1?.procedure.procedureName == 'agentMemoryConfiguration'
 }

  // incorrect init memory
  def "Incorrect init memory"() {
    given : "Incorrect init memory"
    when: "the procedure run"
      def result=runProcedureDsl """
         runProcedure(
           projectName: "/plugins/$pName/project",
           procedureName: "agentMemoryConfiguration",
           actualParameter: [
             initMemory: "NaN",
             maxMemory: "256",
             agent: "local"
           ]
         )"""

    then: "it should error out"
      assert result.outcome == "error"
  }

  // incorrect init memory
  def "Incorrect max memory"() {
    given : "Incorrect init memory"
    when: "the procedure run"
      def result=runProcedureDsl """
         runProcedure(
           projectName: "/plugins/$pName/project",
           procedureName: "agentMemoryConfiguration",
           actualParameter: [
             initMemory: "64",
             maxMemory: "25ff45",
             agent: "local"
           ]
         )"""

    then: "it should error out"
      assert result.outcome == "error"
  }

}
