﻿# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


Function Get-MonkeyEXODLPCompliancePolicy{
    <#
        .SYNOPSIS
		Plugin to get information about DLP compliance policies in Microsoft Exchange Online

        .DESCRIPTION
		Plugin to get information about DLP compliance policies in Microsoft Exchange Online

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyEXODLPCompliancePolicy
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

    [cmdletbinding()]
    Param (
        [Parameter(Mandatory= $false, HelpMessage="Background Plugin ID")]
        [String]$pluginId
    )
    Begin{
        $exo_compliance_dlp_policies = $null
        #Check if already connected to Exchange Online Compliance Center
        $exo_session = Test-EXOConnection -ComplianceCenter
    }
    Process{
        if($exo_session){
            $msg = @{
                MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId, "Security and Compliance DLP compliance policies", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'info';
                InformationAction = $InformationAction;
                Tags = @('SecCompDLPInfo');
            }
            Write-Information @msg
            $exo_compliance_dlp_policies = Get-DlpCompliancePolicy
            if($null -eq $exo_compliance_dlp_policies){
                $exo_compliance_dlp_policies = @{
                    isEnabled = $false
                }
            }
        }
    }
    End{
        if($exo_compliance_dlp_policies){
            $exo_compliance_dlp_policies.PSObject.TypeNames.Insert(0,'Monkey365.SecurityCompliance.DLP.Compliance.Policy')
            [pscustomobject]$obj = @{
                Data = $exo_compliance_dlp_policies
            }
            $returnData.o365_secomp_dlp_compliance_policy = $obj
        }
        else{
            $msg = @{
                MessageData = ($message.MonkeyEmptyResponseMessage -f "Security and Compliance DLP compliance policy", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'warning';
                InformationAction = $InformationAction;
                Tags = @('SecCompDLPEmptyResponse');
            }
            Write-Warning @msg
        }
    }
}
