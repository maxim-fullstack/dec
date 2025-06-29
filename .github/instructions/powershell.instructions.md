---
applyTo: "**/*.ps1,**/*.psm1"
---

### PowerShell (.ps1, .psm1)
- Follow Verb-Noun naming conventions for all functions (e.g., Install-Package, Set-Symlink). Use approved verbs.
- Use [CmdletBinding()] and [Parameter(Mandatory=$true)] attributes for robust parameter handling.
- Write comment-based help for all functions.
- Use Pester for testing.