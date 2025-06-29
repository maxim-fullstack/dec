---
applyTo: "**/*.sh"
---

## Bash (.sh)
- Start all scripts with set -euo pipefail to ensure safe execution.
- Use snake_case for function and variable names (e.g., install_package, dotfile_source_dir).
- Use local for variables inside functions to avoid polluting the global scope.
- Add comments to explain complex commands or logic.
- Always check the return code of critical commands.