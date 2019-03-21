
project 'EC-Admin_Test', {
  description = 'procedure testing'

procedure 'fileExist', {
  description = 'Check to be sure file exist on the server or agent'
  jobNameTemplate = '$[/myProcedure/procedureName]_$[/increment /server/counters/$[/myProject/projectName]/jobCounter]'

  formalParameter 'resource',
    defaultValue: 'local',
    type: 'entry'

  formalParameter 'fileList',
    type: 'textarea',

    required: '1'
  step 'fileExist', {
    description = '''Check that all files exist (1 per line)
'''
    command = '''$[/plugins/EC-Admin/project/scripts/perlHeaderJSON]

my $fileList=getP("fileList");

my $error=0;

# displaying result using foreach loop
foreach my $file (split(\'\\n\', $fileList))
{
  if (-e $file) {
    print "YES $file\\n";
  } else {
    print "NO $file\\n";
    $error++;
  }
}

exit($error);
$[/plugins/EC-Admin/project/scripts/perlLibJSON]
'''
    resourceName = '$[resource]'
    shell = 'ec-perl'
   }
}
  procedure 'artifactRepoSyncTesting', {
    description = 'Do not delete. Called by ec-spec-tools'

    formalParameter 'repoRes', defaultValue: 'win8', {
      description = 'The resource of the repo to test'
      required = '1'
      type = 'entry'
    }

    step 'delete', {
      command = '''$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

use File::Path;

my $dir=$ENV{\'COMMANDER_DATA\'};

if (! $dir) {
  printf("Error: COMMANDER_DATA undefined: $dir\\n");
  exit(1);
}
printf("Delete $dir/repository-data");
rmtree ("$dir/repository-data");
'''
      errorHandling = 'failProcedure'
      resourceName = '$[repoRes]'
      shell = 'ec-perl'
     }

    step 'sync', {
      errorHandling = 'failProcedure'
      subprocedure = 'artifactRepositorySynchronization'
      subproject = '/plugins/EC-Admin/project'
      actualParameter 'artifactRepositoryList', 'default'
      actualParameter 'artifactRepositoryResource', '$[repoRes]'
      actualParameter 'artifactVersionPattern', 'AA:*'
      actualParameter 'batchSize', '25'
    }

    step 'verify', {
      command = '''$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

use File::Path;

my $dir=$ENV{\'COMMANDER_DATA\'};

if (! $dir) {
  printf("Error: COMMANDER_DATA undefined: $dir\\n");
  exit(1);
}
if (! -d "$dir/repository-data/AA/OLHp/3.3.3") {
	printf("Error: cannot find AA/OLHp/3.3.3 in $dir/repository-data");
    exit(1);
}

if (! -d "$dir/repository-data/AA/OLHp/3.3.4") {
	printf("Error: cannot find AA/OLHp/3.3.4 in $dir/repository-data");
    exit(1);
}
'''
      errorHandling = 'failProcedure'
      resourceName = '$[repoRes]'
      shell = 'ec-perl'
     }
  }

  procedure 'cleanJob-LocalWorkspace', {
    step 'echo', {
      command = '''echo "Hellow world"'''
      resourceName = 'ecadmin-win'
      workspaceName = 'ecadmin-win-wks'
    }

    step 'build', {
      errorHandling = 'failProcedure'
       subprocedure = 'Build'
      subproject = 'Training_user'
      actualParameter 'Build Label', 'gfoo'
    }
  }

  procedure 'getPS', {
    description = '''to be called by ntest to verify getP and getPS work as expected
Issue #20'''

    step 'getPSJSON', {
       command = '''$[/plugins/EC-Admin/project/scripts/perlHeaderJSON]

my $hRef=getPS("/server/EC-Admin", 1);
print Dumper($hRef);

my $val=$hRef->{licenseLogger}->{config}->{emailTo};
$ec->setProperty("summary", $val);
exit ($val ne "$[/server/EC-Admin/licenseLogger/config/emailTo]");

$[/plugins/EC-Admin/project/scripts/perlLibJSON]
'''
      shell = 'ec-perl'
    }

    step 'getPSXML', {
      command = '''$[/plugins/EC-Admin/project/scripts/perlHeader]
use Data::Dumper;

my $hRef=getPS("/myProject/PS", 1);
print Dumper($hRef);

my $val=$hRef->{licenseLogger}->{config}->{emailTo};
$ec->setProperty("summary", $val);
exit ($val ne "$[/myProject/PS/licenseLogger/config/emailTo]");

$[/plugins/EC-Admin/project/scripts/perlLib]
'''
      shell = 'ec-perl'
     }
  }

  procedure 'questionMark', {

    step 'rerun?', {
      command = 'echo "I\'m rerunning"'
    }
  }

  procedure 'RP_Test2', {

    step 'step2_1', {
      subprocedure = 'RP_Proc1'
    }
  }

  procedure 'scriptsPropertiesTest', {
    description = '''Test the code in the scripts PS to be sure they can be loaded from a different project
Called by NTEST '''

    step 'humanSize', {
      description = 'Should return 3 Mb'
      command = '''$[/plugins/[EC-Admin]/project/scripts/perlHeaderJSON]
my $res=humanSize(3*1024*1024);

printf("size=%s\\n",$res);
$ec->setProperty("result", $res);

$[/plugins/[EC-Admin]/project/scripts/perlCommonLib]'''
      resourceName = 'ecadmin-lin'
      shell = 'ec-perl'
    }
  }

  procedure 'semaphoreTest', {
    jobNameTemplate = '$[/myProcedure/procedureName]_$[/increment /server/counters/$[/myProject/projectName]/jobCounter]'

    formalParameter 'token', defaultValue: '1', {
      required = '1'
      simpleList = '1|2|3'
      type = 'radio'
    }

    step 'acqToken', {
      subprocedure = 'acquireSemaphore'
      subproject = '/plugins/EC-Admin/project'
      actualParameter 'maxSemaphoreValue', '1'
      actualParameter 'semaphoreProperty', '/projects/EC-Admin_Test/token$[token]'
      actualParameter 'serializationResource', 'Serializer'
    }

    step 'sleep', {
      command = 'sleep 10'
    }

    step 'relToken', {
      subprocedure = 'releaseSemaphore'
      subproject = '/plugins/EC-Admin/project'
      actualParameter 'semaphoreProperty', '/projects/EC-Admin_Test/token$[token]'
      actualParameter 'serializationResource', 'Serializer'
    }

    // Custom properties

    property 'ec_customEditorData', {

      // Custom properties

      property 'parameters', {

        // Custom properties

        property 'token', {

          // Custom properties

          property 'options', {

            // Custom properties
            list = '1|2|3'

            property 'type', value: 'simpleList', {
              expandable = '1'
              suppressValueTracking = '0'
            }
          }
          formType = 'standard'
        }
      }
    }
  }

  procedure 'TestRemoveParameter', {

    step 'CreateProcedure', {
      command = '''$[/plugins/EC-Admin/project/scripts/perlHeaderJSON]

my $proj="$[/myProject/projectName]";

#
# Create callee
#
my($ok,$json)=InvokeCOmmander(\'getProcedure\', "RP_Proc1);
if (! $ok) {
  $ec->createProcedure($proj, "RP_Proc1");
  $ec->createFormalParameter($proj, "RP_Proc1", "param1", {description=>"Test param1"});
}

#
# Create Caller
#
$ec->createProcedure($proj, "RP_Test2");
$ec->createStep($proj, "RP_Test2", "step2_1",
			{
              actualParameter=>[{actualParameterName => \'param1\', value => \'main\'}],
              subprocedure=>"RP_Proc1"
            }
         );

$[/plugins/EC-Admin/project/scripts/perlLibJSON]
'''
      shell = 'ec-perl'
    }

    step 'callTest', {
      subprocedure = 'removeParameterFromCall'
      subproject = '/plugins/EC-Admin/project'
      actualParameter 'debug', 'true'
      actualParameter 'delete', 'true'
      actualParameter 'parameter_Name', 'param1'
      actualParameter 'procedure_Name', 'RP_Proc1'
      actualParameter 'project_Name', 'EC-Admin Test'
    }

    step 'Clean', {
      command = '''$[/plugins/EC-Admin/project/scripts/perlHeaderJSON]

my $proj="$[/myProject/projectName]";

$ec->deleteProcedure($proj, "RP_Proc1");
$ec->deleteProcedure($proj, "RP_Proc2");
'''
      shell = 'ec-perl'
    }
  }

  tag 'ec-admin'

  // Custom properties

  property 'PS', {
    description = ''

    // Custom properties

    property 'cleanup', {

      // Custom properties

      property 'config', {

        // Custom properties

        property 'timeout', value: '600', {
          description = ''
          expandable = '1'
          suppressValueTracking = '0'
        }
      }
    }

    property 'licenseLogger', {

      // Custom properties

      property 'config', {

        // Custom properties
        cleanpOldJobs = '1'

        property 'emailConfig', value: 'default', {
          expandable = '1'
          suppressValueTracking = '0'
        }
        emailTo = 'admin'

        property 'resource', value: 'local', {
          expandable = '1'
          suppressValueTracking = '0'
        }

        property 'workspace', value: 'default', {
          expandable = '1'
          suppressValueTracking = '0'
        }
      }
    }
  }
  token1 = '1'
  token2 = '-1'
  token3 = ''
}
