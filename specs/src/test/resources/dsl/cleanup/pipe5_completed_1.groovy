/* project "pipe5", {
  pipeline "Completed", {
    stage "Stage 1", {

    }
  }
}
*/
  flowRuntime {
    flowRuntimeName = 'Completed_1_20180620221956'
    completed = '1'
    finish = '2018-02-01T17:50:57.352Z'
    flowId = null
    flowName = null
    gateId = null
    gateType = null
    launchedByUser = 'lrochette'
    outcome = 'error'
    pipelineId = null
    pipelineName = 'Completed'
    projectName = 'pipe5'
    releaseId = null
    releaseName = null
    restartCount = '1'
    restartable = '1'
    runAsUser = null
    stageId = null
    stageName = null
    start = '2018-06-20T22:19:56.815Z'
    taskId = null
    taskName = null
    actualParameter 'ec_stagesToRun', '["Stage 1"]'

    flowRuntimeState {
      description = 'gate flow step'
      flowRuntimeStateName = '7dcc1f59-74d7-11e8-b3a5-0a03fa837144_pre_gate_flow_state_14578653704799'
      action = null
      active = '0'
      advancedMode = '0'
      afterLastRetry = null
      alwaysRun = '0'
      colorCode = null
      completed = '1'
      deployerExpression = null
      deployerTask = '0'
      duration = null
      environmentName = null
      environmentProjectName = null
      environmentTemplateName = null
      environmentTemplateProjectName = null
      errorHandling = null
      evidence = null
      flowStateName = '7dcc1f59-74d7-11e8-b3a5-0a03fa837144_pre_gate_flow_state'
      flowStateType = 'task'
      gateCondition = null
      gateType = 'PRE'
      index = '0'
      instruction = null
      keepOnError = '0'
      outcome = 'success'
      plannedEndTime = null
      plannedStartTime = null
      precondition = null
      requiredApprovalsCount = null
      resourceName = null
      retryCount = null
      retryInterval = null
      retryType = null
      rollingDeployEnabled = null
      rollingDeployManualStepAssignees = null
      rollingDeployManualStepCondition = null
      rollingDeployPhases = null
      rootFlowRuntimeId = null
      rootFlowRuntimeName = 'Completed_1_20180620221956'
      runCondition = '1'
      runNumber = '1'
      runType = null
      snapshotName = null
      stageName = 'Stage 1'
      startingStage = null
      subErrorHandling = null
      subapplication = null
      subflow = '769ea85a-74d7-11e8-86b0-0a03fa837144_pregateflow'
      subpipeline = null
      subpluginKey = null
      subprocedure = null
      subprocess = null
      subproject = 'pipe5'
      subrelease = null
      subreleasePipeline = null
      subreleasePipelineProject = null
      subreleaseSuffix = null
      subservice = null
      subworkflowDefinition = null
      subworkflowStartingState = null
      taskName = null
      triggerType = null
      useApproverAcl = '0'
      waitForCompletion = '0'
      waitForPlannedStart = '0'
      waitingForDependency = '0'
      waitingForManualRetry = '0'
      waitingForPlannedStart = '0'
      waitingForPrecondition = '0'
      waitingOnManual = '0'

      flowRuntimeTransition {
        flowRuntimeTransitionName = '103e5b47-74d8-11e8-86b0-0a03fa837144_103f45ab-74d8-11e8-86b0-0a03fa837144'
        condition = null
        index = '0'
        targetFlowRuntimeState = '769dbdf5-74d7-11e8-86b0-0a03fa837144_stage_flow_state_14578659428013'
      }

      flowTaskInfo {
        errorCode = null
        errorMessage = null
        flowRuntimeName = null
        jobName = null
        outcome = 'success'
        processId = null
        workflowName = null
      }
    }

    flowRuntimeState {
      description = 'stage flow step'
      flowRuntimeStateName = '769dbdf5-74d7-11e8-86b0-0a03fa837144_stage_flow_state_14578659428013'
      action = null
      active = '0'
      advancedMode = '0'
      afterLastRetry = null
      alwaysRun = '0'
      colorCode = null
      completed = '1'
      deployerExpression = null
      deployerTask = '0'
      duration = null
      environmentName = null
      environmentProjectName = null
      environmentTemplateName = null
      environmentTemplateProjectName = null
      errorHandling = null
      evidence = null
      flowStateName = '769dbdf5-74d7-11e8-86b0-0a03fa837144_stage_flow_state'
      flowStateType = 'task'
      gateCondition = null
      gateType = null
      index = '1'
      instruction = null
      keepOnError = '0'
      outcome = 'success'
      plannedEndTime = null
      plannedStartTime = null
      precondition = null
      requiredApprovalsCount = null
      resourceName = ''
      retryCount = null
      retryInterval = null
      retryType = null
      rollingDeployEnabled = null
      rollingDeployManualStepAssignees = null
      rollingDeployManualStepCondition = null
      rollingDeployPhases = null
      rootFlowRuntimeId = null
      rootFlowRuntimeName = 'Completed_1_20180620221956'
      runCondition = '1'
      runNumber = '1'
      runType = null
      snapshotName = null
      stageName = 'Stage 1'
      startingStage = null
      subErrorHandling = null
      subapplication = null
      subflow = '769d48bd-74d7-11e8-86b0-0a03fa837144_stageflow'
      subpipeline = null
      subpluginKey = null
      subprocedure = null
      subprocess = null
      subproject = 'pipe5'
      subrelease = null
      subreleasePipeline = null
      subreleasePipelineProject = null
      subreleaseSuffix = null
      subservice = null
      subworkflowDefinition = null
      subworkflowStartingState = null
      taskName = null
      triggerType = null
      useApproverAcl = '0'
      waitForCompletion = '0'
      waitForPlannedStart = '0'
      waitingForDependency = '0'
      waitingForManualRetry = '0'
      waitingForPlannedStart = '0'
      waitingForPrecondition = '0'
      waitingOnManual = '0'

      flowRuntimeTransition {
        flowRuntimeTransitionName = '103f45ab-74d8-11e8-86b0-0a03fa837144_103fbadf-74d8-11e8-86b0-0a03fa837144'
        condition = null
        index = '0'
        targetFlowRuntimeState = '05d91295-74d8-11e8-86b0-0a03fa837144_post_gate_flow_state_14578663042338'
      }

      flowTaskInfo {
        errorCode = null
        errorMessage = null
        flowRuntimeName = null
        jobName = null
        outcome = 'success'
        processId = null
        workflowName = null
      }
    }

    flowRuntimeState {
      description = 'gate flow step'
      flowRuntimeStateName = '05d91295-74d8-11e8-86b0-0a03fa837144_post_gate_flow_state_14578663042338'
      action = null
      active = '0'
      advancedMode = '0'
      afterLastRetry = null
      alwaysRun = '0'
      colorCode = null
      completed = '1'
      deployerExpression = null
      deployerTask = '0'
      duration = null
      environmentName = null
      environmentProjectName = null
      environmentTemplateName = null
      environmentTemplateProjectName = null
      errorHandling = null
      evidence = null
      flowStateName = '05d91295-74d8-11e8-86b0-0a03fa837144_post_gate_flow_state'
      flowStateType = 'task'
      gateCondition = null
      gateType = 'POST'
      index = '2'
      instruction = null
      keepOnError = '0'
      outcome = 'success'
      plannedEndTime = null
      plannedStartTime = null
      precondition = null
      requiredApprovalsCount = null
      resourceName = null
      retryCount = null
      retryInterval = null
      retryType = null
      rollingDeployEnabled = null
      rollingDeployManualStepAssignees = null
      rollingDeployManualStepCondition = null
      rollingDeployPhases = null
      rootFlowRuntimeId = null
      rootFlowRuntimeName = 'Completed_1_20180620221956'
      runCondition = '1'
      runNumber = '1'
      runType = null
      snapshotName = null
      stageName = 'Stage 1'
      startingStage = null
      subErrorHandling = null
      subapplication = null
      subflow = '769f449e-74d7-11e8-86b0-0a03fa837144_postgateflow'
      subpipeline = null
      subpluginKey = null
      subprocedure = null
      subprocess = null
      subproject = 'pipe5'
      subrelease = null
      subreleasePipeline = null
      subreleasePipelineProject = null
      subreleaseSuffix = null
      subservice = null
      subworkflowDefinition = null
      subworkflowStartingState = null
      taskName = null
      triggerType = null
      useApproverAcl = '0'
      waitForCompletion = '0'
      waitForPlannedStart = '0'
      waitingForDependency = '0'
      waitingForManualRetry = '0'
      waitingForPlannedStart = '0'
      waitingForPrecondition = '0'
      waitingOnManual = '0'

      flowTaskInfo {
        errorCode = null
        errorMessage = null
        flowRuntimeName = null
        jobName = null
        outcome = 'success'
        processId = null
        workflowName = null
      }
    }

    flowRuntimeState {
      description = 'gate flow step'
      flowRuntimeStateName = '7dcc1f59-74d7-11e8-b3a5-0a03fa837144_pre_gate_flow_state_14701640824815'
      action = null
      active = '0'
      advancedMode = '0'
      afterLastRetry = null
      alwaysRun = '0'
      colorCode = null
      completed = '1'
      deployerExpression = null
      deployerTask = '0'
      duration = null
      environmentName = null
      environmentProjectName = null
      environmentTemplateName = null
      environmentTemplateProjectName = null
      errorHandling = null
      evidence = null
      flowStateName = '7dcc1f59-74d7-11e8-b3a5-0a03fa837144_pre_gate_flow_state'
      flowStateType = 'task'
      gateCondition = null
      gateType = 'PRE'
      index = '3'
      instruction = null
      keepOnError = '0'
      outcome = 'error'
      plannedEndTime = null
      plannedStartTime = null
      precondition = null
      requiredApprovalsCount = null
      resourceName = null
      retryCount = null
      retryInterval = null
      retryType = null
      rollingDeployEnabled = null
      rollingDeployManualStepAssignees = null
      rollingDeployManualStepCondition = null
      rollingDeployPhases = null
      rootFlowRuntimeId = null
      rootFlowRuntimeName = 'Completed_1_20180620221956'
      runCondition = '1'
      runNumber = '2'
      runType = null
      snapshotName = null
      stageName = 'Stage 1'
      startingStage = null
      subErrorHandling = null
      subapplication = null
      subflow = '769ea85a-74d7-11e8-86b0-0a03fa837144_pregateflow'
      subpipeline = null
      subpluginKey = null
      subprocedure = null
      subprocess = null
      subproject = 'pipe5'
      subrelease = null
      subreleasePipeline = null
      subreleasePipelineProject = null
      subreleaseSuffix = null
      subservice = null
      subworkflowDefinition = null
      subworkflowStartingState = null
      taskName = null
      triggerType = null
      useApproverAcl = '0'
      waitForCompletion = '0'
      waitForPlannedStart = '0'
      waitingForDependency = '0'
      waitingForManualRetry = '0'
      waitingForPlannedStart = '0'
      waitingForPrecondition = '0'
      waitingOnManual = '0'

      flowRuntimeTransition {
        flowRuntimeTransitionName = '598caecd-74d8-11e8-b3a5-0a03fa837144_598d9931-74d8-11e8-b3a5-0a03fa837144'
        condition = null
        index = '0'
        targetFlowRuntimeState = '769dbdf5-74d7-11e8-86b0-0a03fa837144_stage_flow_state_14701646269430'
      }

      flowTaskInfo {
        errorCode = null
        errorMessage = null
        flowRuntimeName = null
        jobName = null
        outcome = 'error'
        processId = null
        workflowName = null
      }
    }

    flowRuntimeState {
      description = 'stage flow step'
      flowRuntimeStateName = '769dbdf5-74d7-11e8-86b0-0a03fa837144_stage_flow_state_14701646269430'
      action = null
      active = '0'
      advancedMode = '0'
      afterLastRetry = null
      alwaysRun = '0'
      colorCode = null
      completed = '0'
      deployerExpression = null
      deployerTask = '0'
      duration = null
      environmentName = null
      environmentProjectName = null
      environmentTemplateName = null
      environmentTemplateProjectName = null
      errorHandling = null
      evidence = null
      flowStateName = '769dbdf5-74d7-11e8-86b0-0a03fa837144_stage_flow_state'
      flowStateType = 'task'
      gateCondition = null
      gateType = null
      index = '4'
      instruction = null
      keepOnError = '0'
      outcome = 'success'
      plannedEndTime = null
      plannedStartTime = null
      precondition = null
      requiredApprovalsCount = null
      resourceName = ''
      retryCount = null
      retryInterval = null
      retryType = null
      rollingDeployEnabled = null
      rollingDeployManualStepAssignees = null
      rollingDeployManualStepCondition = null
      rollingDeployPhases = null
      rootFlowRuntimeId = null
      rootFlowRuntimeName = 'Completed_1_20180620221956'
      runCondition = null
      runNumber = '2'
      runType = null
      snapshotName = null
      stageName = 'Stage 1'
      startingStage = null
      subErrorHandling = null
      subapplication = null
      subflow = '769d48bd-74d7-11e8-86b0-0a03fa837144_stageflow'
      subpipeline = null
      subpluginKey = null
      subprocedure = null
      subprocess = null
      subproject = 'pipe5'
      subrelease = null
      subreleasePipeline = null
      subreleasePipelineProject = null
      subreleaseSuffix = null
      subservice = null
      subworkflowDefinition = null
      subworkflowStartingState = null
      taskName = null
      triggerType = null
      useApproverAcl = '0'
      waitForCompletion = '0'
      waitForPlannedStart = '0'
      waitingForDependency = '0'
      waitingForManualRetry = '0'
      waitingForPlannedStart = '0'
      waitingForPrecondition = '0'
      waitingOnManual = '0'

      flowRuntimeTransition {
        flowRuntimeTransitionName = '598d9931-74d8-11e8-b3a5-0a03fa837144_598e3575-74d8-11e8-b3a5-0a03fa837144'
        condition = null
        index = '0'
        targetFlowRuntimeState = '05d91295-74d8-11e8-86b0-0a03fa837144_post_gate_flow_state_14701650969005'
      }
    }

    flowRuntimeState {
      description = 'gate flow step'
      flowRuntimeStateName = '05d91295-74d8-11e8-86b0-0a03fa837144_post_gate_flow_state_14701650969005'
      action = null
      active = '0'
      advancedMode = '0'
      afterLastRetry = null
      alwaysRun = '0'
      colorCode = null
      completed = '0'
      deployerExpression = null
      deployerTask = '0'
      duration = null
      environmentName = null
      environmentProjectName = null
      environmentTemplateName = null
      environmentTemplateProjectName = null
      errorHandling = null
      evidence = null
      flowStateName = '05d91295-74d8-11e8-86b0-0a03fa837144_post_gate_flow_state'
      flowStateType = 'task'
      gateCondition = null
      gateType = 'POST'
      index = '5'
      instruction = null
      keepOnError = '0'
      outcome = 'success'
      plannedEndTime = null
      plannedStartTime = null
      precondition = null
      requiredApprovalsCount = null
      resourceName = null
      retryCount = null
      retryInterval = null
      retryType = null
      rollingDeployEnabled = null
      rollingDeployManualStepAssignees = null
      rollingDeployManualStepCondition = null
      rollingDeployPhases = null
      rootFlowRuntimeId = null
      rootFlowRuntimeName = 'Completed_1_20180620221956'
      runCondition = null
      runNumber = '2'
      runType = null
      snapshotName = null
      stageName = 'Stage 1'
      startingStage = null
      subErrorHandling = null
      subapplication = null
      subflow = '769f449e-74d7-11e8-86b0-0a03fa837144_postgateflow'
      subpipeline = null
      subpluginKey = null
      subprocedure = null
      subprocess = null
      subproject = 'pipe5'
      subrelease = null
      subreleasePipeline = null
      subreleasePipelineProject = null
      subreleaseSuffix = null
      subservice = null
      subworkflowDefinition = null
      subworkflowStartingState = null
      taskName = null
      triggerType = null
      useApproverAcl = '0'
      waitForCompletion = '0'
      waitForPlannedStart = '0'
      waitingForDependency = '0'
      waitingForManualRetry = '0'
      waitingForPlannedStart = '0'
      waitingForPrecondition = '0'
      waitingOnManual = '0'
    }

    // Custom properties
    ec_stagesToRun = '["Stage 1"]'
    ec_startingStage = 'Stage 1'
  }
