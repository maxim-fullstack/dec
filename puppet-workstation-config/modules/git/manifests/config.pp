# Git configuration class
# Handles Git configuration settings with extensible structure

class git::config {
  
  # Get Git configuration from Hiera with defaults
  $git_config = lookup('git::config', Hash, 'deep', {})
  $git_aliases = lookup('git::aliases', Hash, 'deep', {})
  
  # Default Git configuration if none provided
  $default_config = {
    'user.name'    => 'Developer',
    'user.email'   => 'developer@localhost',
    'core.editor'  => 'nano',
    'init.defaultBranch' => 'main',
    'pull.rebase'  => 'false',
    'core.autocrlf' => $facts['os']['family'] ? {
      'windows' => 'true',
      default   => 'input',
    },
  }
  
  # Merge user config with defaults
  $final_config = $default_config + $git_config
  
  # Apply Git configuration settings
  $final_config.each |String $setting, String $value| {
    exec { "git_config_${setting}":
      command => $facts['os']['family'] ? {
        'windows' => "git config --global ${setting} '${value}'",
        default   => "/usr/bin/git config --global ${setting} '${value}'",
      },
      provider => $facts['os']['family'] ? {
        'windows' => 'powershell',
        default   => 'shell',
      },
      unless => $facts['os']['family'] ? {
        'windows' => "if ((git config --global ${setting}) -eq '${value}') { exit 0 } else { exit 1 }",
        default   => "/usr/bin/test \"\$(/usr/bin/git config --global ${setting})\" = \"${value}\"",
      },
      require => Class['git::install'],
    }
  }
  
  # Apply Git aliases if any are defined
  if !empty($git_aliases) {
    $git_aliases.each |String $alias_name, String $alias_command| {
      exec { "git_alias_${alias_name}":
        command => $facts['os']['family'] ? {
          'windows' => "git config --global alias.${alias_name} '${alias_command}'",
          default   => "/usr/bin/git config --global alias.${alias_name} '${alias_command}'",
        },
        provider => $facts['os']['family'] ? {
          'windows' => 'powershell',
          default   => 'shell',
        },
        unless => $facts['os']['family'] ? {
          'windows' => "if ((git config --global alias.${alias_name}) -eq '${alias_command}') { exit 0 } else { exit 1 }",
          default   => "/usr/bin/test \"\$(/usr/bin/git config --global alias.${alias_name})\" = \"${alias_command}\"",
        },
        require => Class['git::install'],
      }
    }
  }
  
  # Verify configuration
  exec { 'verify_git_config':
    command => $facts['os']['family'] ? {
      'windows' => 'git config --global --list',
      default   => '/usr/bin/git config --global --list',
    },
    provider => $facts['os']['family'] ? {
      'windows' => 'powershell',
      default   => 'shell',
    },
    refreshonly => true,
    subscribe   => Exec[keys($final_config).map |$setting| { "git_config_${setting}" }],
  }
}
