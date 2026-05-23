Write-Host "Task Scheduler | DS: @imsandy.dll" -ForegroundColor Magenta
Write-Host ""
$flagW = @(
    "CMD","cmd","Powershell","Powershell_ISE",
    "TaskScheduler","Task_Scheduler",
    "cheat","clicker","autoclicker",
    "auto","ez","bypass","sstest",
    "suck","scheduler","tonynoh"
)
Write-Host "Analisi Scheduled Tasks..." -ForegroundColor Magenta
Start-Sleep -Seconds 3
function Resolve-PathEnv($path) {
    [Environment]::ExpandEnvironmentVariables($path)
}
function Clean-Args($args) {
    if ([string]::IsNullOrWhiteSpace($args)) {
        return ""
    }
    ($args -replace "\$\([^)]*\)", "").Trim()
}
$tasks = Get-ScheduledTask | Select-Object TaskName,TaskPath,Actions,
foreach ($t in $tasks) {
    $isFlagged = $false
    foreach ($w in $flagW) {
        if ($t.TaskName -match [regex]::Escape($w)) {
            $isFlagged = $true
            break
        }
    }
    if ($isFlagged) {
        Write-Host "[!] $($t.TaskName)" -ForegroundColor Red
    }
    else {
        Write-Host $t.TaskName
    }
}
Write-Host ""
Write-Host "RIEPILOGO TASK CREATE DALL'UTENTE" -ForegroundColor Yellow
$currentUser = $env:USERNAME.ToLower()
$userTasks = @()
foreach ($t in (Get-ScheduledTask)) {
    try {
        $xml = [xml](Export-ScheduledTask -TaskName $t.TaskName -TaskPath $t.TaskPath)
        $author = $xml.Task.RegistrationInfo.Author
        if ($author) {
            $authorLower = $author.ToLower()
            if (
                $authorLower -match [regex]::Escape($currentUser)
            ) {
                $userTasks += [PSCustomObject]@{
                    Task   = $t
                    Author = $author
                }
            }
        }
    }
    catch {

    }
}
if ($userTasks.Count -gt 0) {
    foreach ($u in $userTasks) {
        Write-Host "[USER] $($u.Task.TaskName)" -ForegroundColor Yellow
        Write-Host "   AUTHOR: $($u.Author)" -ForegroundColor DarkYellow
        foreach ($a in $u.Task.Actions) {
            $uexe  = Resolve-PathEnv $a.Execute
            $uargs = Clean-Args $a.Arguments
            Write-Host "   -> $uexe $uargs" -ForegroundColor DarkYellow
        }
    }
}
else {
    Write-Host "Nessuna task utente trovata" -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "RIEPILOGO TASK (FLAGGED)" -ForegroundColor Magenta
foreach ($t in $tasks) {
    $isFlagged = $false
    foreach ($w in $flagW) {
        if ($t.TaskName -match [regex]::Escape($w)) {
            $isFlagged = $true
            break
        }
    }
    if ($isFlagged) {
        Write-Host "[!] $($t.TaskName)" -ForegroundColor Red
    }
}
Write-Host ""
$taskName = Read-Host "Inserisci il nome esatto della task"
$task = Get-ScheduledTask | Where-Object {
    $_.TaskName -eq $taskName
}
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
        $jar = if ($exe -match "\.jar$") {
            $exe
        }
        else {
            ($args -split "\s+")[0]
        }
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
