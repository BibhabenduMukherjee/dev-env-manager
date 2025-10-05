#!/bin/bash

# DevEnv Manager Installation Script
# Supports macOS, Linux, and Windows (via WSL)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Rust if not present
install_rust() {
    if ! command_exists cargo; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        print_success "Rust installed successfully"
    else
        print_info "Rust already installed"
    fi
}

# Install system dependencies
install_dependencies() {
    local os=$(detect_os)
    
    case $os in
        "macos")
            if ! command_exists brew; then
                print_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            print_info "Installing system dependencies..."
            brew install git curl wget
            ;;
        "linux")
            if command_exists apt-get; then
                print_info "Installing system dependencies (Ubuntu/Debian)..."
                sudo apt-get update
                sudo apt-get install -y git curl wget build-essential
            elif command_exists yum; then
                print_info "Installing system dependencies (CentOS/RHEL)..."
                sudo yum install -y git curl wget gcc gcc-c++ make
            elif command_exists pacman; then
                print_info "Installing system dependencies (Arch Linux)..."
                sudo pacman -S --noconfirm git curl wget base-devel
            else
                print_warning "Unknown Linux distribution. Please install git, curl, wget, and build tools manually."
            fi
            ;;
        "windows")
            print_warning "Windows detected. Please install Git for Windows and ensure you have a Unix-like environment (WSL recommended)."
            ;;
        *)
            print_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Build and install DevEnv Manager
install_devenv() {
    print_info "Building DevEnv Manager..."
    
    # Clone or update repository
    if [ -d "dev-env-manager" ]; then
        print_info "Updating existing repository..."
        cd dev-env-manager
        git pull
    else
        print_info "Cloning repository..."
        git clone https://github.com/yourusername/dev-env-manager.git
        cd dev-env-manager
    fi
    
    # Build the project
    cargo build --release
    
    # Install binary
    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"
    
    if [ -f "target/release/devenv" ]; then
        cp target/release/devenv "$install_dir/"
        chmod +x "$install_dir/devenv"
        print_success "DevEnv Manager installed to $install_dir"
    else
        print_error "Build failed. Binary not found."
        exit 1
    fi
    
    # Add to PATH if not already present
    if ! echo "$PATH" | grep -q "$install_dir"; then
        print_info "Adding $install_dir to PATH..."
        echo "export PATH=\"$install_dir:\$PATH\"" >> "$HOME/.bashrc"
        echo "export PATH=\"$install_dir:\$PATH\"" >> "$HOME/.zshrc"
        print_warning "Please restart your shell or run 'source ~/.bashrc' to use devenv command"
    fi
}

# Setup DevEnv Manager configuration
setup_config() {
    print_info "Setting up DevEnv Manager configuration..."
    
    local devenv_dir="$HOME/.devenv"
    mkdir -p "$devenv_dir"
    
    # Create default configuration
    cat > "$devenv_dir/config.yaml" << EOF
devenv_dir: $devenv_dir
environments_dir: $devenv_dir/environments
plugins_dir: $devenv_dir/plugins
cache_dir: $devenv_dir/cache
log_level: info
auto_update: true
team_sync: false
security_scan: true
performance_monitoring: true
EOF
    
    print_success "Configuration created at $devenv_dir/config.yaml"
}

# Main installation function
main() {
    print_info "🚀 Installing DevEnv Manager..."
    
    # Detect OS
    local os=$(detect_os)
    print_info "Detected OS: $os"
    
    # Install dependencies
    install_dependencies
    
    # Install Rust
    install_rust
    
    # Install DevEnv Manager
    install_devenv
    
    # Setup configuration
    setup_config
    
    print_success "🎉 DevEnv Manager installed successfully!"
    print_info "Run 'devenv --help' to get started"
    print_info "Run 'devenv init' to initialize your first project"
}

# Run main function
main "$@"
