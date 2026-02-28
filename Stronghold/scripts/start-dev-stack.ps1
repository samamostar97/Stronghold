param(
    [string]$AvdName,
    [string]$MobileDeviceId,
    [string]$DesktopDeviceId = "windows",
    [string]$DesktopApiUrl = "http://localhost:5034",
    [string]$MobileApiUrl = "http://10.0.2.2:5034",
    [switch]$SkipTestServer,
    [switch]$SkipDesktop,
    [switch]$SkipMobile,
    [switch]$SkipEmulator
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not (Test-Path -Path $PathValue)) {
        throw "$Label not found: $PathValue"
    }
}

function Get-AndroidSdkPath {
    $candidates = @(
        $env:ANDROID_SDK_ROOT,
        $env:ANDROID_HOME,
        (Join-Path $env:LOCALAPPDATA "Android\Sdk")
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "Android SDK not found. Set ANDROID_SDK_ROOT or install SDK in %LOCALAPPDATA%\Android\Sdk."
}

function Get-RunningEmulatorSerials {
    param([Parameter(Mandatory = $true)][string]$AdbExe)

    $lines = & $AdbExe devices
    return $lines |
        Select-Object -Skip 1 |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -match '^emulator-\d+\s+device$' } |
        ForEach-Object { ($_ -split '\s+')[0] }
}

function Start-TerminalWindow {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $escapedWorkdir = $WorkingDirectory.Replace("'", "''")
    $script = @"
`$Host.UI.RawUI.WindowTitle = '$Title'
Set-Location '$escapedWorkdir'
$Command
"@

    Start-Process -FilePath "powershell.exe" -ArgumentList @(
        "-NoExit",
        "-ExecutionPolicy",
        "Bypass",
        "-Command",
        $script
    ) | Out-Null
}

function Resolve-EmulatorSerial {
    param(
        [Parameter(Mandatory = $true)][string]$AdbExe,
        [Parameter(Mandatory = $true)][string]$EmulatorExe,
        [string]$RequestedAvd
    )

    $existing = @(Get-RunningEmulatorSerials -AdbExe $AdbExe)
    if ($existing.Count -gt 0) {
        Write-Host "Emulator already running: $($existing[0])"
        return $existing[0]
    }

    $avd = $RequestedAvd
    if ([string]::IsNullOrWhiteSpace($avd)) {
        $avds = @(& $EmulatorExe -list-avds | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        if ($avds.Count -eq 0) {
            throw "No Android AVD found. Create one in Android Studio Device Manager first."
        }
        $avd = $avds[0]
    }

    Write-Host "Starting Android emulator: $avd"
    Start-Process -FilePath $EmulatorExe -ArgumentList @("-avd", $avd) | Out-Null

    $serial = $null
    for ($i = 0; $i -lt 90; $i++) {
        Start-Sleep -Seconds 2
        $current = @(Get-RunningEmulatorSerials -AdbExe $AdbExe)
        if ($current.Count -gt 0) {
            $serial = $current[0]
            break
        }
    }

    if (-not $serial) {
        throw "Emulator process started, but device not detected by adb."
    }

    Write-Host "Waiting emulator boot completion: $serial"
    for ($i = 0; $i -lt 120; $i++) {
        $bootCompleted = (& $AdbExe -s $serial shell getprop sys.boot_completed 2>$null).Trim()
        if ($bootCompleted -eq "1") {
            Write-Host "Emulator booted: $serial"
            return $serial
        }
        Start-Sleep -Seconds 2
    }

    throw "Emulator detected, but boot did not complete in time."
}

$solutionRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$workspaceRoot = Split-Path -Path $solutionRoot -Parent

$testServerProject = Join-Path $solutionRoot "Stronghold.TestServer\Stronghold.TestServer.csproj"
$desktopPath = Join-Path $workspaceRoot "stronghold_desktop"
$mobilePath = Join-Path $workspaceRoot "stronghold_mobile"

Assert-PathExists -PathValue $testServerProject -Label "TestServer project"
Assert-PathExists -PathValue $desktopPath -Label "Desktop project folder"
Assert-PathExists -PathValue $mobilePath -Label "Mobile project folder"

$emulatorSerial = $null

if (-not $SkipMobile -and -not $MobileDeviceId -and -not $SkipEmulator) {
    $sdkPath = Get-AndroidSdkPath
    $emulatorExe = Join-Path $sdkPath "emulator\emulator.exe"
    $adbExe = Join-Path $sdkPath "platform-tools\adb.exe"

    Assert-PathExists -PathValue $emulatorExe -Label "Android emulator executable"
    Assert-PathExists -PathValue $adbExe -Label "adb executable"

    $emulatorSerial = Resolve-EmulatorSerial -AdbExe $adbExe -EmulatorExe $emulatorExe -RequestedAvd $AvdName
}

if (-not $SkipTestServer) {
    Start-TerminalWindow `
        -Title "Stronghold TestServer" `
        -WorkingDirectory $solutionRoot `
        -Command "dotnet run --project `"$testServerProject`" --urls http://localhost:5034"
}

if (-not $SkipDesktop) {
    Start-TerminalWindow `
        -Title "Stronghold Desktop" `
        -WorkingDirectory $desktopPath `
        -Command "flutter run -d $DesktopDeviceId --dart-define=API_BASE_URL=$DesktopApiUrl"
}

if (-not $SkipMobile) {
    $targetDevice = $MobileDeviceId
    if ([string]::IsNullOrWhiteSpace($targetDevice) -and $emulatorSerial) {
        $targetDevice = $emulatorSerial
    }

    $deviceArg = ""
    if (-not [string]::IsNullOrWhiteSpace($targetDevice)) {
        $deviceArg = "-d $targetDevice"
    }

    Start-TerminalWindow `
        -Title "Stronghold Mobile" `
        -WorkingDirectory $mobilePath `
        -Command "flutter run $deviceArg --dart-define=API_BASE_URL=$MobileApiUrl"
}

Write-Host ""
Write-Host "Started dev stack:"
if (-not $SkipTestServer) { Write-Host "  - TestServer: http://localhost:5034" }
if (-not $SkipDesktop)    { Write-Host "  - Desktop Flutter target: $DesktopDeviceId" }
if (-not $SkipMobile) {
    $mobileTargetLabel = $MobileDeviceId
    if ([string]::IsNullOrWhiteSpace($mobileTargetLabel) -and $emulatorSerial) {
        $mobileTargetLabel = $emulatorSerial
    }
    if ([string]::IsNullOrWhiteSpace($mobileTargetLabel)) {
        $mobileTargetLabel = "default"
    }
    Write-Host "  - Mobile Flutter target: $mobileTargetLabel"
}
