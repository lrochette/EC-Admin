package com.electriccloud.plugin.spec
import org.apache.tools.ant.BuildLogger

/*
Copyright 2018-2019 Electric Cloud, Inc.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import com.electriccloud.spec.*

class PluginTestHelper extends PluginSpockTestSupport {
  static def automationTestsContextRun = System.getenv ('AUTOMATION_TESTS_CONTEXT_RUN') ?: ''

  def redirectLogs(String parentProperty = '/myJob') {
    def propertyLogName = parentProperty + '/debug_logs'
    dsl """
      setProperty(
        propertyName: "/plugins/EC-Admin/project/ec_debug_logToProperty",
        value: "$propertyLogName"
      )
    """
    return propertyLogName
  }

  def getJobLogs(def jobId) {
    assert jobId
    def logs
    try {
        logs = getJobProperty("/myJob/debug_logs", jobId)
    } catch (Throwable e) {
        logs = "Possible exception in logs; check job"
    }
    logs
  }

  def runProcedureDslAndRename(jobName, dslString) {
    println "##LR Running runProcedureDslAndRename"
    redirectLogs()
    assert dslString
    println "##LR dstString" + dslString

    def result = dsl(dslString)
    assert result.jobId

    logger.debug( "Renaming job to $jobName")
    def counter=incrementP("/server/counters/$pName/jobCounter")
    setProperty("/jobs/${result.jobId}/jobName", "saveAllObjects_${jobName}_$counter")

    waitUntil {
     jobCompleted result.jobId
    }
    def logs = getJobLogs(result.jobId)
    def outcome = jobStatus(result.jobId).outcome
    logger.debug("DSL: $dslString")
    logger.debug("Logs: $logs")
    logger.debug("Outcome: $outcome")
    [logs: logs, outcome: outcome, jobId: result.jobId]
  }

  def runProcedureDsl(dslString) {
    redirectLogs()
    assert dslString

    def result = dsl(dslString)
    assert result.jobId
    waitUntil {
      jobCompleted result.jobId
    }
    def logs = getJobLogs(result.jobId)
    def outcome = jobStatus(result.jobId).outcome
    logger.debug("DSL: $dslString")
    logger.debug("Logs: $logs")
    logger.debug("Outcome: $outcome")
    [logs: logs, outcome: outcome, jobId: result.jobId]
  }

  def getP(String path) {
    def result = dsl """getProperty(propertyName: "$path")"""
    return result?.property.value
  }

 def incrementP(String path) {
   def result = dsl """incrementProperty(propertyName: "$path")"""
   return result?.property.value
 }

  def getStepProperty(def jobId, def stepName, def propName) {
    assert jobId
    assert propName

    def prop
    def property = "/myJob/jobSteps/$stepName/$propName"
    println "##LR Trying to get property: $property, jobId: $jobId"
    try {
      prop = getJobProperty(property, jobId)
    } catch (Throwable e) {
      logger.debug("Can't retrieve Upper Step Summary from the property: '$property'; check job: " + jobId)
    }
    return prop
  }

  def getStepSummary(def jobId, def stepName){
    return getStepProperty(jobId, stepName, "summary")
  }

  def conditionallyDeleteProject(String projectName){
    if (System.getenv("LEAVE_TEST_PROJECTS")){
      return
    }
    dsl "deleteProject(projectName: '$projectName')"
  }

  def conditionallyDeleteDirectory(String dir) {
    if (System.getenv("LEAVE_TEST_DIRECTORIES")){
      return
    }
    new AntBuilder().delete(dir:"$dir" )
  }

  def fileExist(String filename) {
    def file=new File(filename)
    return file.exists()
  }

  def importXML(String filename) {
    def res=dsl """import (fileName: "$filename", force: "1")"""
    assert res
  }
}
