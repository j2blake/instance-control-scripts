# Not independently executable

=begin
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
=end

require 'distro'
require 'instance'
require 'instance_control_properties'
require 'property_file_reader'
require 'template_processor'
require 'tomcat_status'
require 'keys'

#
# Helpful classes and utility methods.
#
class UserInputError < StandardError
end

class SettingsError < StandardError
end

def bogus(message)
  puts(">>>>>>>>>>>>>BOGUS #{message}")
end

def warning(message)
  puts("WARNING: #{message}")
end

#
# Initialize the current settings.
#
$settings_file = ENV['HOME']+'/.instance-control.properties'

$settings = InstanceControlProperties.new()
