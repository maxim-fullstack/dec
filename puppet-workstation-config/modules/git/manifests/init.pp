# Git module - handles Git installation and configuration
# Follows clean architecture with separation of installation and configuration

class git {
  # Ensure platform detection is available
  require platform
  
  # Include installation and configuration classes
  include git::install
  include git::config
  
  # Ensure installation happens before configuration
  Class['git::install'] -> Class['git::config']
}
