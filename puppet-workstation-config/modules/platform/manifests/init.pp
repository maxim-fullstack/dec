# Platform detection module
# Provides cross-platform abstractions and platform-specific facts

class platform {
  
  # Validate that we're running on a supported platform
  case $facts['os']['family'] {
    'windows': {
      $platform_supported = true
      $package_manager = 'winget'
    }
    'Debian': {
      $platform_supported = true
      $package_manager = 'apt'
    }
    default: {
      $platform_supported = false
      fail("Unsupported platform: ${facts['os']['family']}. This module supports Windows and Debian/Ubuntu only.")
    }
  }

  # Set platform-specific facts for use by other modules
  if $platform_supported {
    # Create a fact for the package manager
    $package_manager_fact = $package_manager
    
    notify { "Platform detected: ${facts['os']['family']} using ${package_manager}":
      loglevel => 'info',
    }
  }
}
