#Last changed here: 2026-02-10

# Map network drive
net use "\\FileShareHost\Backups\SomeFolderName" /USER:backupsusername password

# Run robocopy and capture exit code
robocopy C:\Whatever\Folder\You\Want\To\Backup "\\FileShareHost\Backups\SomeFolderName" /e /mir
$robocopyExitCode = $LASTEXITCODE

# Robocopy exit codes:
# 0 = No files copied (no errors)
# 1 = Files copied successfully
# 2 = Extra files or directories detected
# 3 = Files copied + extra files detected
# 4 or higher = Errors occurred

if ($robocopyExitCode -ge 4) {
    # Robocopy failed - create Syncro alert
    Import-Module $env:SyncroModule
    
    $alertMessage = "Backup copy failed with exit code: $robocopyExitCode. Please check the backup process."
    
    Rmm-Alert -Category "Backup Failed" -Body $alertMessage
    
    Write-Host "ERROR: Robocopy failed with exit code $robocopyExitCode" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Backup completed successfully (Exit code: $robocopyExitCode)" -ForegroundColor Green
    exit 0
}
