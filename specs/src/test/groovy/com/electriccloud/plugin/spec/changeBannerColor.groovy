package com.electriccloud.plugin.spec
import spock.lang.*
import org.apache.tools.ant.BuildLogger

class changeBannerColor extends PluginTestHelper {
  static String pName='EC-Admin'
  @Shared String pluginName
  @Shared String installDir

  def doSetupSpec() {
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

  // Banner color files
  def "Banner color files"() {
    given : "a list of color"
      Boolean defaultPresent=false
    when: "looping through"
      def props=dsl """
        getProperties(
          path: "/projects/$pluginName/procedures/changeBannerColor/ec_customEditorData/parameters/color/options"
        ) """
    then: "the files should be found"
      props.each { prop ->
        def propName=prop.propertyName
        println "Color: $propName"
        if (propName ==~ /option/) {
          println "Color: $propName"
          def color=getP("/projects/$pluginName/procedures/changeBannerColor/ec_customEditorData/parameters/color/options/$propName/value")
          if ($color == "Default") {
            defaultPresent = true
          }
        } else {
          println "Skip: $propName"
        }
        assert File("$installDir/plugins/$pluginName/htdocs/frame_bannerBg_$color.gif")
      }
      assert defaultPresent == "true"
  }

}
