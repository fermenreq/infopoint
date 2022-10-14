# GNU GENERAL PUBLIC LICENSE
# Version 3, 29 June 2007

# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.

# Permissions of this strong copyleft license are conditioned on making available complete source code of 
# licensed works and modifications, which include larger works using a licensed work, under the same license. 
# Copyright and license notices must be preserved. Contributors provide an express grant of patent rights.

Import-Module -Name .\modules.ps1 -Force

function start-remediation-process{
    [cmdletbinding()]
    Param(
        
        [Parameter(Mandatory=$true)]
        [string]$process_path,

        [Parameter(Mandatory=$true)]
        [string]$log_path,

        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [pscredential]$credentials

    )

    # Variables 
    $is_rebooted = $false
    $looked = $false
    $is_process_running= $false
    $error_message = $null

    try{

       do{
            # Check if the process is up and running..
            $process_status = get-process-status -process_path $process_path -log_path $log_path
            $is_process_running = $process_status[0]
            $process_name = $process_status[1]
            
            # The process is not running .. starting it..
            if(-not $is_process_running){
                $result_process = start-process -processName $process_name -log_path $log_path
                
                # The process is up and running
                if($result_process){
                    enable-Trace($false, "The process is up and running. Exit", $log_path)
                    break
                } # The host is rebooted. Locked it and notify IT department
                elseif($is_rebooted){
                    start-looked -ComputerName $ComputerName -log_path $log_path
                    $looked = $true
                    break
                }
                else{
                    # Starting reboot .. 
                    $result_reboot = start-reboot -ComputerName $ComputerName -Credential $credentials -log_path $log_path
                    if(-not $result_reboot){
                        enable-Trace($true, "Reboot has been failed. See the full logs.", $log_path)
                        break
                    }
                    else{
                        $is_rebooted = $true
                    }
                }
            } # The process is up and running. End
            else{
                enable-Trace($false, "The process is up and running. Exit", $log_path)
                break
            }
       }
       while(-not $looked )

    }
    catch{
        $error_message = $Error[0].Exception.GetType().FullName
        enable-Trace($true, $error_message, $log_path)
    }
}