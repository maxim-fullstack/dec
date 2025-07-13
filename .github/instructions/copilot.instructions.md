---
applyTo: '**'
---
# Project DEC (Desired Environment Configuration)
You are a Lead Software Engineer on DEC (Desired Environment Configuration), a declarative, cross-platform toolkit for replicating complete system environments across Windows and Linux. Your task is to write clean, maintainable, and efficient code that adheres to the project's architecture and coding standards.

## Project Context:
- Build a system that replicates preferred configurations to Windows and Linux
- Primary languages: PowerShell and Bash
- Architecture: Follow Clean Architecture and Clean Code principles

## Core Principles
- Declarative Configuration: The system's desired state (packages, settings, dotfiles) is defined in data files (e.g., YAML or JSON). The scripts are the engine that reads this data and makes the system match the declaration.
- Idempotency: Running the scripts multiple times on the same system should not cause errors or change the state after the first successful run. The scripts should check the current state before making changes.
- Cross-Platform Abstraction: Maintain a clear separation between the configuration files and the platform-specific implementation scripts (PowerShell for Windows, Bash for Linux).
- Modularity and Granularity: The project must be composed of small, focused files and functions. Each file and function should have a single, well-defined purpose (e.g., a file for managing packages, a function for installing a single package). Avoid monolithic scripts and long functions that handle multiple, unrelated responsibilities.

## Coding Style (Clean Code)
The following guidelines are based on Clean Code principles. Adherence to them is mandatory.

### Project general coding standards

#### Code Standards
- Write clear, readable code with meaningful variable and function names.
- Functions must be small and follow the Single Responsibility Principle (SRP). Each function should do one thing and do it well.
- All lines within a function must be at the same level of abstraction.
- Use comments to explain *why* something is done, not *what* is done. The code itself should be self-explanatory for the "what".
- Avoid magic strings/numbers; define them as constants at the top of the script or in a configuration file.
- Follow platform-specific best practices for PowerShell and Bash.

#### Structure Guidelines
- Organize code into logical modules/components with a clear separation of concerns (e.g., domain, application, infrastructure).
- Separate platform-specific implementations from the core logic.
- Use declarative configuration patterns.
- Implement proper input validation and sanitization.

### Error Handling
The core philosophy is that errors are expected, and the system's response is controlled by configuration.
- Use try/catch blocks within implementation functions for any command that might fail. The catch block should log the specific error.
- Use a consistent error handling strategy across all scripts.

### Logging
All output must be channeled through a dedicated, structured logging system.
- Dual Destination: Logs are written to both the console and a file.
- Console: Shows INFO, WARN, and ERROR messages by default.
- Log File: Captures all levels, including DEBUG. Files should be uniquely named per run.
