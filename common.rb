# Not independently executable

=begin
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
=end

require 'instance_control_properties'
require 'property_file_reader'
require 'template_processor'
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

def is_git(path)
  File.exists?(File.expand_path('.git', path))
end

def get_revision_info(path)
  revision_info = File.expand_path('revisionInfo', path)
  begin
    File.readlines(revision_info)[0].chomp
  rescue
    nil
  end
end

#
# Initialize the current settings.
#
$settings_file = ENV['HOME']+'/.instance-control.properties'

$settings = InstanceControlProperties.new()
