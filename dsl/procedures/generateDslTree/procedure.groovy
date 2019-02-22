import java.io.File

/*

Author: L. Rochette

#  Copyright 2013-2019 Electric-Cloud Inc.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

History:
------------------------------------------------------------------------------
2019-02-11 lrochette    Initial version based on saveDslObjects
*/

def procName= 'generateDslTree'

procedure procName,
  description: 'generateDsl for a full tree to be used with EC-DslDeploy',
  jobNameTemplate: '$[/plugins/EC-Admin/project/scripts/jobTemplate]',
{

  step 'grabResource',
    description: '''Capture the resource in case local is a pool.
All steps need to run on the same host''',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/grabResource.sh").text,
    errorHandling: 'abortProcedure',
    resourceName: '$[pool]'

  step 'saveSteps',
    description: 'A step to export each steps individually',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/saveSteps.pl").text,
    resourceName: '$[/myJob/backupResource]',
    shell: 'ec-perl'
}
