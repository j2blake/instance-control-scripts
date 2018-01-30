=begin
--------------------------------------------------------------------------------

Stuff that all of the main scripts want to do:
  require the helper scripts
  create some global variables
  set up some handy global methods

--------------------------------------------------------------------------------
=end

#
# Helpful classes and utility methods.
#
class UserInputError < StandardError
end

class SettingsError < StandardError
end

def warning(message)
  puts("WARNING: #{message}")
end

module Kernel
  def bogus(message)
    puts
    puts(">>>>>>>>>>>>>BOGUS #{message}")
    puts
  end
end

require 'fileutils'

require 'instance_stub'
require 'property_file_reader'

#require 'distro'
#require 'hash_monkey_patch'
#require 'knowledge_base'
#require 'property_file_reader'
#require 'running_tomcats'
#require 'site'
#require 'template_processor'
#require 'tomcat'

$settings_file = ENV['HOME']+'/.instance-control.properties'
#$instance = Instance.from_settings_file($settings_file)

