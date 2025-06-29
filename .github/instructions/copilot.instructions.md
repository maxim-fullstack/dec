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
- Modularity and Granularity: The project must be composed of small, focused files. Each file should have a single, well-defined purpose (e.g., managing packages, handling dotfiles). Avoid monolithic scripts that handle multiple, unrelated responsibilities.

## Coding Style (Clean Code)

### Project general coding standards

#### Code Standards
- Write clear, readable code with meaningful variable and function names
- Implement proper separation of concerns with distinct layers (domain, application, infrastructure)
- Use dependency injection and abstraction where appropriate
- Include comprehensive and robust error handling and logging
- Write modular, testable functions with single responsibilities
- Avoid magic strings/numbers; define them as constants at the top of the script or in a configuration file.
- Follow platform-specific best practices for PowerShell and Bash
- Functions should be small and follow the Single Responsibility Principle.
- Use descriptive, unambiguous names for variables and functions.
- Single Responsibility & Single Level of Abstraction: Every function must do one thing. All lines within a function must be at the same level of abstraction.
- Use comments to explain why something is done, not what is done. The code should be self-explanatory for the "what".

#### Structure Guidelines
- Organize code into logical modules/components
- Separate platform-specific implementations
- Use declarative configuration patterns
- Implement proper input validation and sanitization

### Error Handling
The core philosophy is that errors are expected, and the system's response is controlled by configuration.
- Use try/catch blocks within implementation functions for any command that might fail. The catch block should log the specific error.
- Use a consistent error handling strategy across all scripts.

### Logging
All output must be channeled through a dedicated, structured logging system.
- Dual Destination: Logs are written to both the console and a file.
- Console: Shows INFO, WARN, and ERROR messages by default.
- Log File: Captures all levels, including DEBUG. Files should be uniquely named per run.