# Main site manifest for workstation configuration
# This is the entry point for the Puppet masterless configuration

# Set default file permissions
File {
  owner => 'root',
  group => 'root',
  mode  => '0644',
}

# Include platform detection and core modules
include platform
include git

# Node classification - applies to all nodes in masterless mode
node default {
  # Ensure platform facts are available
  require platform

  # Apply Git configuration
  include git
  
  # Display completion message
  notify { 'Workstation configuration complete':
    message => 'Puppet workstation configuration has been successfully applied.',
  }
}
