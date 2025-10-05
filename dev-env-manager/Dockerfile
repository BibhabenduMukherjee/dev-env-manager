# Multi-stage Dockerfile for DevEnv Manager
# Supports building for multiple platforms

# Build stage
FROM rust:1.75-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 devenv

# Set working directory
WORKDIR /workspace

# Copy binary from builder stage
COPY --from=builder /app/target/release/devenv /usr/local/bin/devenv

# Make binary executable
RUN chmod +x /usr/local/bin/devenv

# Switch to non-root user
USER devenv

# Set environment variables
ENV DEVENV_HOME=/home/devenv/.devenv
ENV PATH="/usr/local/bin:${PATH}"

# Create devenv directory
RUN mkdir -p $DEVENV_HOME

# Default command
CMD ["devenv", "--help"]
