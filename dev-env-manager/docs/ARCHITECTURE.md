# DevEnv Manager Architecture

## Overview

DevEnv Manager is built with a modular, plugin-based architecture that provides cross-platform compatibility and extensibility. The system is designed to be fast, reliable, and easy to extend.

## Core Components

### 1. Core Engine (`src/core.rs`)
The main orchestrator that coordinates all other components:
- **DevEnvManager**: Main struct that handles high-level operations
- **Project lifecycle management**: init, setup, switch, remove
- **Team collaboration**: share, import, sync
- **Health monitoring**: status, health checks

### 2. Configuration System (`src/config.rs`)
Handles all configuration management:
- **Config**: Global DevEnv Manager settings
- **ProjectConfig**: Project-specific configuration
- **EnvironmentConfig**: Environment-specific settings
- **YAML-based**: Human-readable configuration format

### 3. Project Detection (`src/detect.rs`)
Intelligent project analysis:
- **Multi-language support**: Node.js, Python, Go, Rust, Java, PHP, Ruby
- **Framework detection**: React, Vue, Angular, FastAPI, Django, etc.
- **Tool detection**: Docker, Git, CI/CD configurations
- **Version detection**: From package files, version files, etc.

### 4. Environment Management (`src/env.rs`)
Environment lifecycle management:
- **Environment creation**: Setup and configuration
- **Environment switching**: Seamless transitions
- **Health monitoring**: Performance and issue detection
- **Sharing**: Export/import environments

### 5. Plugin System (`src/plugins.rs`)
Extensible language and tool support:
- **LanguagePlugin trait**: Common interface for all plugins
- **Built-in plugins**: Node.js, Python, Go, Rust, Java, PHP, Ruby
- **Plugin management**: Installation, updates, health checks
- **Dependency management**: Automatic dependency resolution

### 6. Utilities (`src/utils.rs`)
Cross-platform utility functions:
- **File operations**: Cross-platform file handling
- **Process management**: Command execution and monitoring
- **System information**: OS detection, architecture info
- **Path handling**: Cross-platform path operations

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    DevEnv Manager                           │
├─────────────────────────────────────────────────────────────┤
│  CLI Interface (clap)                                      │
├─────────────────────────────────────────────────────────────┤
│  Core Engine (DevEnvManager)                               │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Config    │ │   Detect    │ │    Env      │          │
│  │  Manager    │ │  Manager    │ │  Manager    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Plugin    │ │   Utils     │ │  Security   │          │
│  │  Manager    │ │  Manager    │ │  Manager    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  Language Plugins (Node.js, Python, Go, Rust, etc.)       │
├─────────────────────────────────────────────────────────────┤
│  System Integration (nvm, pyenv, rustup, etc.)            │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Project Initialization
```
User runs: devenv init
    ↓
Core Engine detects project type
    ↓
Project Detector analyzes files
    ↓
Configuration created (devenv.yml)
    ↓
Environment setup begins
```

### 2. Environment Setup
```
User runs: devenv setup
    ↓
Project Detector identifies requirements
    ↓
Plugin Manager installs languages/tools
    ↓
Dependencies installed
    ↓
Environment configured
    ↓
Health check performed
```

### 3. Environment Switching
```
User runs: devenv switch <name>
    ↓
Environment Manager validates environment
    ↓
Current environment deactivated
    ↓
Target environment activated
    ↓
Environment variables updated
    ↓
Status updated
```

## Configuration Hierarchy

### 1. Global Configuration (`~/.devenv/config.yaml`)
```yaml
devenv_dir: ~/.devenv
environments_dir: ~/.devenv/environments
plugins_dir: ~/.devenv/plugins
cache_dir: ~/.devenv/cache
log_level: info
auto_update: true
team_sync: false
security_scan: true
performance_monitoring: true
```

### 2. Project Configuration (`devenv.yml`)
```yaml
name: "my-project"
version: "1.0.0"
description: "My awesome project"
languages:
  - nodejs: "20.10.0"
  - python: "3.11.0"
tools:
  - docker: "latest"
environment:
  NODE_ENV: "development"
scripts:
  setup: "npm install"
  dev: "npm run dev"
```

### 3. Environment Configuration (`~/.devenv/environments/<name>/config.yaml`)
```yaml
name: "my-project"
version: "1.0.0"
created_at: "2024-01-01T00:00:00Z"
status: "active"
languages:
  nodejs: "20.10.0"
  python: "3.11.0"
health:
  status: "healthy"
  performance: "good"
  issues: []
  recommendations: []
```

## Plugin System

### Plugin Interface
```rust
pub trait LanguagePlugin {
    fn name(&self) -> &str;
    fn setup(&self, version: &str) -> Result<(), Box<dyn std::error::Error>>;
    fn update(&self, version: &str) -> Result<(), Box<dyn std::error::Error>>;
    fn install_dependencies(&self) -> Result<(), Box<dyn std::error::Error>>;
    fn check_health(&self) -> Result<bool, Box<dyn std::error::Error>>;
}
```

### Built-in Plugins
- **NodeJSPlugin**: Manages Node.js via nvm
- **PythonPlugin**: Manages Python via pyenv
- **GoPlugin**: Manages Go via g
- **RustPlugin**: Manages Rust via rustup
- **JavaPlugin**: Manages Java via SDKMAN
- **PHPPlugin**: Manages PHP via phpenv
- **RubyPlugin**: Manages Ruby via rbenv

## Cross-Platform Support

### Operating Systems
- **macOS**: Intel and Apple Silicon
- **Linux**: Ubuntu, Debian, CentOS, Arch, etc.
- **Windows**: PowerShell, CMD, WSL

### Architecture Support
- **x86_64**: Intel/AMD 64-bit
- **aarch64**: ARM 64-bit (Apple Silicon, ARM servers)
- **i686**: 32-bit x86 (legacy support)

### Package Managers
- **macOS**: Homebrew, MacPorts
- **Linux**: apt, yum, pacman, zypper
- **Windows**: Chocolatey, Scoop, winget

## Security Features

### Built-in Security
- **Dependency scanning**: Check for vulnerabilities
- **Secret detection**: Scan for exposed secrets
- **Permission management**: Proper file permissions
- **Sandboxing**: Isolated environments

### Security Scanning
```bash
devenv security scan          # Full security scan
devenv security audit        # Dependency audit
devenv security secrets       # Secret scanning
```

## Performance Optimization

### Caching Strategy
- **Dependency caching**: Reuse common dependencies
- **Binary caching**: Cache compiled binaries
- **Configuration caching**: Cache parsed configurations

### Resource Management
- **Memory optimization**: Efficient memory usage
- **CPU optimization**: Parallel operations
- **Disk optimization**: Minimal disk usage

## Extensibility

### Custom Plugins
Developers can create custom plugins:

```rust
pub struct MyCustomPlugin;

impl LanguagePlugin for MyCustomPlugin {
    fn name(&self) -> &str { "my-custom" }
    fn setup(&self, version: &str) -> Result<(), Box<dyn std::error::Error>> {
        // Custom setup logic
        Ok(())
    }
    // ... implement other methods
}
```

### Configuration Extensions
Add custom configuration options:

```yaml
# devenv.yml
custom_settings:
  my_setting: "value"
  another_setting: 42
```

## Error Handling

### Error Types
- **Configuration errors**: Invalid YAML, missing files
- **Network errors**: Download failures, connectivity issues
- **Permission errors**: File access, installation permissions
- **Dependency errors**: Missing dependencies, version conflicts

### Error Recovery
- **Automatic retry**: Network operations
- **Fallback strategies**: Alternative installation methods
- **User guidance**: Clear error messages and solutions

## Testing Strategy

### Unit Tests
- **Core functionality**: Individual component testing
- **Plugin testing**: Language plugin validation
- **Utility testing**: Cross-platform utility functions

### Integration Tests
- **End-to-end workflows**: Complete user workflows
- **Cross-platform testing**: OS-specific behavior
- **Performance testing**: Speed and resource usage

### Test Coverage
- **Code coverage**: >90% line coverage
- **Branch coverage**: All code paths tested
- **Integration coverage**: All workflows tested
