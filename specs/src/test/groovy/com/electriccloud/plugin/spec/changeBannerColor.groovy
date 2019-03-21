package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class changeBannerColor extends PluginTestHelper {
  static String pName='EC-Admin'
  @Shared String pluginName
  @Shared String installDir

  def doSetupSpec() {
    dslFile 'dsl/EC-Admin_Test.groovy'
    this.pluginName=getP("/plugins/$pName/project/projectName")
    this.installDir=getP("/server/Electric Cloud/installDirectory")
  }

  def doCleanupSpec() {
  }

  // Check procedures exist
  def "checkProcedures for changeBannerColor"() {
    given:
    when:
      def res1=dsl """
        getProcedure(
          projectName: "/plugins/$pName/project",
          procedureName: "changeBannerColor"
        ) """

    then:
      assert res1?.procedure.procedureName == 'changeBannerColor'
 }

  // Check that the color files are present for each color in the menu
  def "Banner logo files"() {
    given : "a list of logo"
    when: "looping through"
      def count=getP("/projects/$pluginName/procedures/changeBannerColor/ec_customEditorData/parameters/logo/options/optionCount").toInteger()

    then: "the files should be found"
       for (def index = 1; index <= count; index++) {
        def logo=getP("/projects/$pluginName/procedures/changeBannerColor/ec_customEditorData/parameters/logo/options/option$index/value")
        assert fileExist("$installDir/plugins/$pluginName/htdocs/$logo")
      }
  }

}
