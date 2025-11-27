# run-godot-tests.ps1
$ErrorActionPreference = "Continue"

# Path to your Godot binary
$godot = "C:\Godot\GodotEXE\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64_console.exe"

# Run tests and capture output (NO console output)
$processOutput = & $godot --headless --path . --run-tests 2>&1 | Out-String

# Write full output to log file
$processOutput | Set-Content -Path "godot-tests.log"

# PASS case
if ($processOutput -match "TestChessGame:\s*PASS") {
    Write-Host "Tests passed."
    exit 0
}

# FAIL case → extract failing test lines
$failLines = $processOutput -split "`n" | Where-Object { $_ -match "^TestFail" }

if ($failLines.Count -gt 0) {
    $failLines | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "Tests failed."
}

exit 1