import spock.lang.*
import com.electriccloud.spec.PluginSpockTestSupport

class EC-AdminTest extends PluginSpockTestSupport {
  def doSetupSpec() {
    dsl """
        project "EC-Admin_Test", {
        }
    """
  }

    def doCleanupSpec() {
        dsl """
            deleteProject("EC-Admin_Test")
        """
    }

    def "check the plugin is promoted"() {
        when: 'the plugin is promoted'
            def result = dsl """
                promotePlugin("EC-Admin")
            """
        then: 'the procedure finishes'
            assert result?.pluingVersion != null
            waitUntil {
                jobCompleted result.jobId
            }
    }

    def "always failing"() {
        when: 'something happens'
            println "TODO"
        then: 'assertion fails'
            assert false
    }
}
