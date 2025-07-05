# DEC Configuration Templates

This directory contains template files used by the DEC (Desired Environment Configuration) system to generate configuration files during the setup process.

## Template Files

### PowerShellProfile.ps1
- **Purpose**: Template for the PowerShell profile that gets created on the target system
- **Contains**: Aliases, functions, prompt customization, and module imports
- **Applied to**: `$PROFILE.AllUsersAllHosts` path
- **Features**:
  - Common aliases (ll, la, grep, touch, which)
  - Navigation functions with approved PowerShell verbs
  - Git shortcuts with proper aliases
  - Custom prompt with Git branch display
  - Auto-import of posh-git if available

### GitConfig.template
- **Purpose**: Template for Git global configuration
- **Contains**: Comprehensive Git aliases, settings, and color configuration
- **Applied to**: `~/.gitconfig` file
- **Features**:
  - 25+ useful Git aliases
  - VS Code integration for merge/diff tools
  - Enhanced color configuration
  - Modern Git settings (auto-setup remote, prune on fetch, etc.)

## Template Processing

Templates are processed by the `TemplateManager.psm1` module which:

1. **Loads** template files from this directory
2. **Processes** variable substitutions (e.g., `$(Get-Date)`)
3. **Returns** processed content to DSC scripts
4. **Provides** fallback content if template loading fails

## Usage in DSC

Templates are used in `CustomConfiguration.ps1` via the TemplateManager module:

```powershell
# Load PowerShell profile template
$templateDir = Join-Path $using:PSScriptRoot "Templates"
$profileContent = Get-PowerShellProfileTemplate -TemplateDirectory $templateDir

# Process template with current date
$processedContent = Invoke-TemplateProcessing -TemplateContent $profileContent
```

## Benefits of This Approach

### 1. **Separation of Concerns**
- Configuration logic separated from template content
- DSC scripts focus on deployment logic
- Templates focus on content structure

### 2. **Maintainability**
- Easy to modify templates without touching DSC code
- Clear structure for different configuration types
- Version control friendly (separate diffs for logic vs content)

### 3. **Reusability**
- Templates can be shared across different configurations
- Can be extended for other platforms (Linux/macOS)
- Easy to create variations for different environments

### 4. **Testability**
- Templates can be tested independently
- Template processing logic is isolated and testable
- Fallback mechanisms ensure robustness

## Adding New Templates

To add a new template:

1. Create the template file in this directory
2. Add a corresponding function in `TemplateManager.psm1`
3. Update the DSC configuration to use the new template
4. Add the template to the validation list in `Test-TemplateFiles`

## Template Variables

Currently supported template variables:
- `$(Get-Date)` - Current date/time
- Custom variables can be passed via the `Invoke-TemplateProcessing` function

Example with custom variables:
```powershell
$variables = @{ 
    'UserName' = 'John Doe'
    'Email' = 'john@example.com' 
}
$processed = Invoke-TemplateProcessing -TemplateContent $template -Variables $variables
```
