# DevEnv Manager Installation Script for Windows PowerShell
# Requires PowerShell 5.1 or later

param(
    [switch]$Force,
    [string]$InstallPath = "$env:USERPROFILE\.local\bin"
)

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    White = "White"
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Colors.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Colors.Red
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Install Chocolatey if not present
function Install-Chocolatey {
    if (-not (Test-Command choco)) {
        Write-Info "Installing Chocolatey package manager..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Success "Chocolatey installed successfully"
    } else {
        Write-Info "Chocolatey already installed"
    }
}

# Install system dependencies
function Install-Dependencies {
    Write-Info "Installing system dependencies..."
    
    # Install Git
    if (-not (Test-Command git)) {
        choco install git -y
    }
    
    # Install curl
    if (-not (Test-Command curl)) {
        choco install curl -y
    }
    
    # Install wget
    if (-not (Test-Command wget)) {
        choco install wget -y
    }
    
    # Install Visual Studio Build Tools
    if (-not (Test-Command cl)) {
        choco install visualstudio2019buildtools -y
    }
    
    Write-Success "System dependencies installed"
}

# Install Rust
function Install-Rust {
    if (-not (Test-Command cargo)) {
        Write-Info "Installing Rust..."
        Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "rustup-init.exe"
        .\rustup-init.exe -y
        Remove-Item "rustup-init.exe"
        $env:PATH += ";$env:USERPROFILE\.cargo\bin"
        Write-Success "Rust installed successfully"
    } else {
        Write-Info "Rust already installed"
    }
}

# Build and install DevEnv Manager
function Install-DevEnv {
    Write-Info "Building DevEnv Manager..."
    
    # Clone or update repository
    if (Test-Path "dev-env-manager") {
        Write-Info "Updating existing repository..."
        Set-Location "dev-env-manager"
        git pull
    } else {
        Write-Info "Cloning repository..."
        git clone https://github.com/yourusername/dev-env-manager.git
        Set-Location "dev-env-manager"
    }
    
    # Build the project
    cargo build --release
    
    # Create install directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force
    }
    
    # Install binary
    if (Test-Path "target\release\devenv.exe") {
        Copy-Item "target\release\devenv.exe" "$InstallPath\devenv.exe"
        Write-Success "DevEnv Manager installed to $InstallPath"
    } else {
        Write-Error "Build failed. Binary not found."
        exit 1
    }
    
    # Add to PATH if not already present
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$InstallPath*") {
        Write-Info "Adding $InstallPath to PATH..."
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$InstallPath", "User")
        Write-Warning "Please restart your PowerShell session to use devenv command"
    }
}

# Setup DevEnv Manager configuration
function Setup-Config {
    Write-Info "Setting up DevEnv Manager configuration..."
    
    $devenvDir = "$env:USERPROFILE\.devenv"
    if (-not (Test-Path $devenvDir)) {
        New-Item -ItemType Directory -Path $devenvDir -Force
    }
    
    # Create default configuration
    $configContent = @"
devenv_dir: $devenvDir
environments_dir: $devenvDir\environments
plugins_dir: $devenvDir\plugins
cache_dir: $devenvDir\cache
log_level: info
auto_update: true
team_sync: false
security_scan: true
performance_monitoring: true
"@
    
    $configContent | Out-File -FilePath "$devenvDir\config.yaml" -Encoding UTF8
    Write-Success "Configuration created at $devenvDir\config.yaml"
}

# Main installation function
function Main {
    Write-Info "🚀 Installing DevEnv Manager on Windows..."
    
    # Install Chocolatey
    Install-Chocolatey
    
    # Install dependencies
    Install-Dependencies
    
    # Install Rust
    Install-Rust
    
    # Install DevEnv Manager
    Install-DevEnv
    
    # Setup configuration
    Setup-Config
    
    Write-Success "🎉 DevEnv Manager installed successfully!"
    Write-Info "Run 'devenv --help' to get started"
    Write-Info "Run 'devenv init' to initialize your first project"
}

# Run main function
Main
