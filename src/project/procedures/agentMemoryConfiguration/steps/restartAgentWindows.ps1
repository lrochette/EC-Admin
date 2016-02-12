#############################################################################
#
#  restartAgent -- Script to possibly restart an agent.
#  Copyright 2016 Electric-Cloud Inc.
#
#############################################################################

$DebugPreference = "Continue"

ectool setProperty "summary"  "Restarting the agent"
$future= (get-date).AddMinutes(+1).ToString("HH:mm")
Write-Debug "Future $future"

$Time = New-ScheduledTaskTrigger -Once -At $future
#Write-Debug $Time.ToString()

#$User = "Contoso\Administrator"
#$PS = PowerShell.exe sc start commanderAgent
#Register-ScheduledTask -TaskName "RestartAgent" -Trigger $Time  –Action $PS

#sc stop commanderAgent

