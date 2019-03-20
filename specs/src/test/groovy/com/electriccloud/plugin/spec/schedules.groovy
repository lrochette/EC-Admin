package com.electriccloud.plugin.spec
import spock.lang.*

class schedules extends PluginTestHelper {

  def doSetupSpec() {
  }

  def doCleanupSpec() {
  }


  // Check properties /plugins/EC-Admin/projects/scripts work properly
  def "checkProcedures for schedule"() {
    given:
    when:
      def res1=dsl """
        getProcedure(
          projectName: "/plugins/EC-Admin/project",
          procedureName: "schedulesDisable"
        ) """
      def res2=dsl """
        getProcedure(
          projectName: "/plugins/EC-Admin/project",
          procedureName: "schedulesEnable"
        ) """

    then:
      assert res1?.procedure.procedureName == 'schedulesDisable'
      assert res2?.procedure.procedureName == 'schedulesEnable'
 }

}
