param (
    [Parameter(Mandatory=$true)][string]$fileName
)
$fileExists = Test-Path -path $fileName

if($fileExists -eq $false){
    Read-Host "Could not find the file $fileName. Please hit enter to exit the script."
    exit
}

$contents = Get-Content $fileName
$results = @{}

foreach($line in $contents){
    $line = $line.replace("`"","")
    $cells = $line.split(",")
    $date = $cells[1].split(" ")[0].replace("/","-")
    $fullDuration = $cells[2].split(" ")

    $hours = 0
    $minutes = 0

    if($fullDuration.length -eq 1){
        #Line is blank, so continue to next entry and ignore this one.
        continue
    }
    elseif($fullDuration.length -eq 2){
        #Only hours or only minutes
        $qualifier = $fullDuration[1]
        if($qualifier -eq "min" -or $qualifier -eq "mins"){
            $minutes = [int]$fullDuration[0]
        }
        elseif($qualifier -eq "hr" -or $qualifier -eq "hrs"){
            $hours = [int]$fullDuration[0]
        }
        else{
            Read-Host "Something went wrong for the following entry: $line."
        }
    }
    elseif($fullDuration.length -eq 4){
        #Hours and minutes
        $hours = [int]$fullDuration[0]
        $minutes = [int]$fullDuration[2]
    }
    else{
        continue
    }

    $totalTimeInMinutes = [decimal]($hours * 60) + $minutes
    $totalTimeHours = [decimal][math]::round($totalTimeInMinutes / 60,2)

    $currentDateEntry = $results[$date]
    if(!$currentDateEntry){
        $results[$date] = $totalTimeHours
    }
    else {
        $results[$date] = $results[$date] + $totalTimeHours
    }
}

$output = @()
foreach($entry in $results){
    $output += New-Object PSObject -Property $entry
}
$currentDate = Get-Date -Format FileDateTime
$output | Export-Csv -Path "Results-$currentDate.csv"