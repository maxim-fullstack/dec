# Git installation class
# Handles platform-specific Git installation using approved package managers

class git::install {
  
  # Get platform-specific package information from Hiera
  $git_package_name = lookup('git::package_name', String, 'first', 'git')
  $package_manager = lookup('git::package_manager', String, 'first', 'unknown')
  
  # Validate package manager
  case $package_manager {
    'winget': {
      # Windows installation using winget
      exec { 'install_git_winget':
        command  => "winget install --id ${git_package_name} --silent --accept-package-agreements --accept-source-agreements",
        provider => 'powershell',
        unless   => 'Get-Command git -ErrorAction SilentlyContinue',
        timeout  => 600,
        require  => Class['platform'],
      }
      
      # Refresh PATH after installation on Windows
      exec { 'refresh_path_after_git_install':
        command     => 'refreshenv',
        provider    => 'powershell',
        refreshonly => true,
        subscribe   => Exec['install_git_winget'],
      }
    }
    'apt': {
      # Update package cache first
      exec { 'apt_update_for_git':
        command => '/usr/bin/apt-get update',
        unless  => '/usr/bin/test $(($(date +%s) - $(stat -c %Y /var/cache/apt/pkgcache.bin 2>/dev/null || echo 0))) -lt 86400',
        require => Class['platform'],
      }
      
      # Debian/Ubuntu installation using apt
      package { 'git':
        ensure  => 'present',
        name    => $git_package_name,
        require => Exec['apt_update_for_git'],
      }
    }
    default: {
      fail("Unsupported package manager: ${package_manager}. Only 'winget' and 'apt' are supported.")
    }
  }
  
  # Verify Git installation
  exec { 'verify_git_installation':
    command => $facts['os']['family'] ? {
      'windows' => 'git --version',
      default   => '/usr/bin/git --version',
    },
    provider => $facts['os']['family'] ? {
      'windows' => 'powershell',
      default   => 'shell',
    },
    require => $package_manager ? {
      'winget' => Exec['refresh_path_after_git_install'],
      'apt'    => Package['git'],
      default  => undef,
    },
  }
}
