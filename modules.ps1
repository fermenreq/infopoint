
function enable-Trace{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [bool]$result,

        [Parameter(Mandatory=$true)]
        [string]$message,

        [Parameter(Mandatory=$true)]
        [string]$path

    )
    
    $error_result = $null
    [string]$dateTime = get-date -format "yyyy-MM-dd-HH:mm:ss"
    $log_file = $dateTime+".log"

    $log_path= $path,$log_file -join("\")
 
    switch ($result) {
        $true { $error_result = "ERROR" }
        $false { $error_result = "INFO" } 
    }

    $dateTime+" - "+$error_result+" - "+$message+"\r\n" | Out-File $log_path -Append

}

function get-process-status {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string] $process_path,

        [Parameter(Mandatory=$true)]
        [string]$log_path
    )
    
    $process_up_running= $true
    $process = $process_path.Split("\")[-1]
    enable-Trace($false, "Checking if the process: "+$process+" is up and running...", $log_path)
    $error.clear()

    try{
       
        $processDetails = Get-Process -name $process -ErrorAction SilentlyContinue
    
        if(-not $processDetails.Id){
           $error_ = $Error[0].Exception.GetType().FullName
           $process_up_running = $false
           if($error_){
                enable-Trace($true, $error_, $log_path)
           }
        }
    }
    catch{
        $message = $Error[0].Exception.GetType().FullName
        enable-Trace($true, $message, $log_path)
        $process_up_running= $false
    }
   
    return $process_up_running, $process
}

function start-process{
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string] $processName,

        [Parameter(Mandatory=$true)]
        [string]$log_path
    )
    $error.Clear()
    $result = $false

    try{
        $process_status = Start-Process $processName -PassThru -WindowsStyle Hidden -RedirectStandardError $log_path -RedirectStandardOutput $log_path

        if($process_status.Id){
            enable-Trace($false, "Proccess is starting..", $log_path)
            enable-Trace($false, "Proccess ID: "+$process_status.ID, $log_path)
            enable-Trace($false, "Waiting 2 min "+$process_status.ID, $log_path)
            Start-Sleep(120)
            
            $result= $true
        }
        else{
            $message = $Error[0].Exception.GetType().FullName
            enable-Trace($true, $message, $log_path)
        }
    }
    catch{
        $message = $Error[0].Exception.GetType().FullName
        enable-Trace($true, $message, $log_path)
    }

    return $result
}

function reboot{
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string] $ComputerName,

        [Parameter(Mandatory=$true)]
        [pscredential]$credentials,

        [Parameter(Mandatory=$true)]
        [string]$log_path
    )
    $error.Clear()
    $rebooted = $true
    
    enable-Trace($false, "Reboot the system: "+$ComputerName, $log_path)

    try{
        Restart-Computer -ComputerName $ComputerName -Credential $credentials -Wait -For PowerShell -Timeout 300 -Delay 2
    }
    catch{
        $message = $Error[0].Exception.GetType().FullName
        enable-Trace($true, $message, $log_path)
        $rebooted = $false
    }
    return $rebooted
}

function looked{
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string] $ComputerName,

        [Parameter(Mandatory=$true)]
        [string]$log_path
    )
    $error.Clear()
    $message = "The machine: "+$ComputerName+" has been looked and the support team has been notified"
    enable-Trace($false, $message, $log_path)

    return $message
}