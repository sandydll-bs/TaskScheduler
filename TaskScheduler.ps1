Write-Host "Task Scheduler | DS: @imsandy.dll" -ForegroundColor Magenta
Write-Host ""

$flagW = @(
    "update","updater","service","servicehost","host","runtime",
    "system","sys","windows","win","security","defender","check","scan",
    "auto","autostart","autorun","scheduler","task","job",
    "clicker","autoclicker","macro","bot","script","runner",
    "bypass","hack","cheat","inject","injector","loader","crack","patch",
    "sstest","test","debug","dev","trial","temp","tmp",
    "powershell","cmd","cmd.exe","pwsh","powershell_ise",
    "mshta","wscript","cscript","rundll32","regsvr32",
    "certutil","bitsadmin","wmic","msbuild","installutil",
    "schtasks","taskeng","taskhost","taskschd",
    "encoded","base64","hidden","bypassuac","amsi","obf","obfusc",
    "loader","dropper","stealer","miner","rat","trojan","backdoor",
    "inject","payload","beacon","c2","command","control",
    "tonynoh","test123","aaa","zzz","tempjob","updatejob","sysjob",
    "random","default","serviceupdate","windowsupdatex",
    "cheatengine","engine","trainer","speedhack","wallhack","aimbot"
)
Write-Host -ForegroundColor Magenta "Analisi Scheduled Tasks..."
Start-Sleep -Seconds 3
function Resolve-PathEnv($path) {
    return [Environment]::ExpandEnvironmentVariables($path)
}
function Clean-Args($args) {
    if ([string]::IsNullOrWhiteSpace($args)) { return "" }
    return ($args -replace "\$\([^)]*\)", "").Trim()
}
$tasks = Get-ScheduledTask | Select-Object TaskName, TaskPath, Actions
foreach ($t in $tasks) {
    $isFlagged = $flagW | Where-Object {
        $t.TaskName -match [regex]::Escape($_)
    }
    if ($isFlagged) {
        Write-Host "[!] $($t.TaskName)" -ForegroundColor Red
    }
    else {
        Write-Host $t.TaskName
    }
}
Write-Host ""
Write-Host "RIEPILOGO TASK (FLAGGED)" -ForegroundColor Magenta
$flaggedTasks = $tasks | Where-Object {
    $flagW | Where-Object {
        $_ -and $_ -ne "" -and $t.TaskName -match [regex]::Escape($_)
    }
}
foreach ($t in $tasks) {
    $isFlagged = $flagW | Where-Object {
        $t.TaskName -match [regex]::Escape($_)
    }
    if ($isFlagged) {
        Write-Host "[!] $($t.TaskName)" -ForegroundColor Red
    }
}
Write-Host ""
$taskName = Read-Host "Inserisci il nome esatto della task"
$task = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }
if (-not $task) {
    Write-Host "Task non trovata" -ForegroundColor Red
    return
}
Write-Host ""
Write-Host "Analisi contenuto task..." -ForegroundColor Cyan
foreach ($a in $task.Actions) {
    $exe  = Resolve-PathEnv $a.Execute
    $args = Clean-Args $a.Arguments
    Write-Host "DEBUG: $exe $args" -ForegroundColor Cyan
    if ($exe -match "\.jar$" -or $args -match "\.jar") {
        $jar = if ($exe -match "\.jar$") { $exe } else { ($args -split "\s+")[0] }
        $jar = $jar.Trim('"')
        if (Test-Path $jar) {
            Write-Host "Eseguo JAR: $jar" -ForegroundColor Yellow
            Start-Process "java" -ArgumentList "-jar `"$jar`""
        }
        else {
            Write-Host "JAR non trovato: $jar" -ForegroundColor Red
        }
        continue
    }
    if ($exe -and $exe.Trim() -ne "") {
        if (-not (Test-Path $exe)) {
            Write-Host "File non trovato: $exe" -ForegroundColor Red
            continue
        }
        if ([string]::IsNullOrWhiteSpace($args)) {
            Start-Process $exe
        }
        else {
            Start-Process $exe -ArgumentList $args
        }
        Write-Host "Eseguo: $exe $args" -ForegroundColor Green
    }
    else {
        Write-Host "Action non valida" -ForegroundColor Red
    }
}
