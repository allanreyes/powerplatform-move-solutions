# Download and install the Power Platform CLI
Invoke-WebRequest https://aka.ms/PowerAppsCLI -OutFile pac.msi
msiexec /i pac.msi /norestart /quiet

# Update to the latest version
pac install latest

# Log in to Power Platform
pac auth create

# Select the source environment, target environment and solution to be exported

Write-Host 'List of Environments you have access to:' -ForegroundColor Yellow
pac org list
Write-Host '----------------------------------------' -ForegroundColor Yellow

Write-Host 'Which one is your SOURCE environment:' -ForegroundColor Green
$source = Read-Host

Write-Host 'Which one is your TARGET environment:' -ForegroundColor Green
$target = Read-Host

# Select the solutions to be exported

Write-Host 'List of Solutions in your source environment:' -ForegroundColor Yellow
pac solution list
Write-Host '----------------------------------------' -ForegroundColor Yellow
Write-Host 'Which solution would you like to export:' -ForegroundColor Green
$solution = Read-Host

Write-Host 'Copy to target as a managed solution? (Y/N)' -ForegroundColor Green
$isManagedPrompt = Read-Host
$isManaged = $isManagedPrompt.ToUpper() -eq 'Y'

pac org select --environment "$source"

#Export
if($isManaged) {
    Write-Host 'Exporting solution as managed' -ForegroundColor Green
    pac solution export --path "$($solution).zip" --name "$solution" --managed true --include general
} else {
    Write-Host 'Exporting solution as unmanaged' -ForegroundColor Green
    pac solution export --path "$($solution).zip" --name "$solution" --managed false --include general
}

#Check
pac solution check --path "$($solution).zip"

#Create settings file
pac solution create-settings `
--solution-zip "$($solution).zip" `
--settings-file "$($solution).DeploymentSettings.json"

# Update settings file if needed

# Import
Write-Host 'Switching to TARGET environment' -ForegroundColor Green
pac org select --environment "$target"
 
pac solution import --path "$($solution).zip" --settings-file "$($solution).DeploymentSettings.json"
