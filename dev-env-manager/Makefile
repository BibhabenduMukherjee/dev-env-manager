# DevEnv Manager Makefile
# Cross-platform build and development commands

.PHONY: help build test install clean dev lint format check

# Default target
help:
	@echo "DevEnv Manager - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  dev          - Run in development mode"
	@echo "  build        - Build the project"
	@echo "  test         - Run tests"
	@echo "  lint         - Run linter"
	@echo "  format       - Format code"
	@echo "  check        - Run all checks"
	@echo ""
	@echo "Installation:"
	@echo "  install      - Install DevEnv Manager"
	@echo "  install-deps - Install dependencies"
	@echo "  clean        - Clean build artifacts"
	@echo ""
	@echo "Cross-platform:"
	@echo "  build-all    - Build for all platforms"
	@echo "  release      - Create release builds"

# Development commands
dev:
	cargo run

build:
	cargo build --release

test:
	cargo test

lint:
	cargo clippy -- -D warnings

format:
	cargo fmt

check: lint test
	@echo "All checks passed!"

# Installation commands
install: build
	@echo "Installing DevEnv Manager..."
	@mkdir -p ~/.local/bin
	@cp target/release/devenv ~/.local/bin/
	@chmod +x ~/.local/bin/devenv
	@echo "✅ DevEnv Manager installed to ~/.local/bin/"

install-deps:
	@echo "Installing dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install git curl wget; \
	elif command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y git curl wget build-essential; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y git curl wget gcc gcc-c++ make; \
	elif command -v pacman >/dev/null 2>&1; then \
		sudo pacman -S --noconfirm git curl wget base-devel; \
	fi

clean:
	cargo clean
	@echo "Cleaned build artifacts"

# Cross-platform builds
build-all:
	@echo "Building for all platforms..."
	@echo "Building for Linux x86_64..."
	cargo build --release --target x86_64-unknown-linux-gnu
	@echo "Building for macOS x86_64..."
	cargo build --release --target x86_64-apple-darwin
	@echo "Building for macOS ARM64..."
	cargo build --release --target aarch64-apple-darwin
	@echo "Building for Windows x86_64..."
	cargo build --release --target x86_64-pc-windows-gnu

release: build-all
	@echo "Creating release packages..."
	@mkdir -p dist
	@cp target/x86_64-unknown-linux-gnu/release/devenv dist/devenv-linux-x86_64
	@cp target/x86_64-apple-darwin/release/devenv dist/devenv-macos-x86_64
	@cp target/aarch64-apple-darwin/release/devenv dist/devenv-macos-arm64
	@cp target/x86_64-pc-windows-gnu/release/devenv.exe dist/devenv-windows-x86_64.exe
	@echo "Release packages created in dist/"

# Docker commands
docker-build:
	docker build -t devenv-manager .

docker-run:
	docker run -it --rm -v $(PWD):/workspace devenv-manager

# CI/CD commands
ci: check build test
	@echo "CI pipeline completed successfully"

# Documentation
docs:
	cargo doc --open

# Setup development environment
setup:
	@echo "Setting up development environment..."
	@if [ ! -d ".git" ]; then git init; fi
	@if [ ! -f "Cargo.toml" ]; then echo "Error: Not in a Rust project directory"; exit 1; fi
	@echo "✅ Development environment ready"

# Quick start
quickstart: install
	@echo "🚀 DevEnv Manager is ready!"
	@echo "Run 'devenv init' to get started with your first project"
