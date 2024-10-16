# Ensure the script runs from the current directory
cd $PSScriptRoot

# Check if Python and pip are installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Python is not installed. Please install Python first." -ForegroundColor Red
    exit 1
}
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Host "Error: pip is not installed. Please install pip first." -ForegroundColor Red
    exit 1
}

# Install the required Python packages
Write-Host "Installing required Python packages..."
try {
    pip install -r requirements.txt -ErrorAction Stop
    Write-Host "Requirements installed successfully." -ForegroundColor Green
} catch {
    Write-Host "Installing packages manually..."
    pip install openai==0.27.0 python-dotenv distro PyYAML pyperclip termcolor colorama aiohttp keyring urllib3==1.26.6
}

# Ask the user if they want to upgrade OpenSSL
$upgradeSSL = Read-Host "Do you want to upgrade OpenSSL? (y/n)"
if ($upgradeSSL -match "^[yY]$") {
    pip install --upgrade urllib3 pyOpenSSL
    Write-Host "OpenSSL upgrade completed."
} else {
    Write-Host "Skipping OpenSSL upgrade."
}

# Loading animation
function Show-Loading {
    $loadingSteps = @("▓▒▒▒▒▒▒▒▒▒▒▒▒▒", "▓▓▒▒▒▒▒▒▒▒▒▒▒▒", "▓▓▓▒▒▒▒▒▒▒▒▒▒▒", "▓▓▓▓▓▓▓▒▒▒▒▒▒▒", "▓▓▓▓▓▓▓▓▓▓▓▓▓▓")
    foreach ($step in $loadingSteps) {
        Clear-Host
        Write-Host "$step Loading ..." -ForegroundColor Green
        Start-Sleep -Milliseconds 100
    }
}
Show-Loading

# Define target directory
$TargetDir = "$HOME\combot"
if (Test-Path $TargetDir) {
    Write-Host "Error: Target directory $TargetDir already exists. Aborting. (Use or Remove)" -ForegroundColor Red
    exit 1
}

# Clone the repository
Write-Host "- Cloning the repository..."
git clone https://github.com/blueraymusic/Combot.git $TargetDir

# Set permissions and copy files
cd $TargetDir
Write-Host "- Copying files..."
Copy-Item computer.py, prompt.txt, computer.yaml $TargetDir -Force
$TargetFullPath = "$TargetDir\computer.py"
icacls $TargetFullPath /grant Everyone:F

# Add aliases to PowerShell profile
$ProfilePath = [Environment]::GetFolderPath('MyDocuments') + "\PowerShell\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path $ProfilePath)) {
    New-Item -ItemType File -Path $ProfilePath -Force
}

Write-Host "- Adding aliases to PowerShell profile..."
Add-Content -Path $ProfilePath -Value "`nfunction computer { python '$TargetFullPath' }"
Add-Content -Path $ProfilePath -Value "`nfunction bot { python '$TargetFullPath' }"

# Reload PowerShell profile
Write-Host "`n- Reloading the PowerShell profile..."
. $ProfilePath

# Verify aliases
if (-not (Get-Alias computer -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Alias 'computer' was not set correctly." -ForegroundColor Red
    Write-Host "Please manually add: function computer { python '$TargetFullPath' }"
    exit 1
}

if (-not (Get-Alias bot -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Alias 'bot' was not set correctly." -ForegroundColor Red
    Write-Host "Please manually add: function bot { python '$TargetFullPath' }"
    exit 1
}

# Completion message
Write-Host "`nReload/Reopen PowerShell to activate aliases." -ForegroundColor Yellow
Write-Host "Voilaa!!! Done."
Write-Host "Make sure you have the OpenAI API key set in one of these options:"
Write-Host "  - Environment variable"
Write-Host "  - .env file or an ~/.openai.apikey file"
Write-Host "  - In computer.yaml"
Write-Host "  - Use: 'computer --API : API_KEY'"

Write-Host "`nFor more information, use the command: 'computer -i'"
Write-Host "Have fun!" -ForegroundColor Green
