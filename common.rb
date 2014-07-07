=begin
--------------------------------------------------------------------------------

Stuff that all of the main scripts want to do:
  require the helper scripts
  create some global variables
  set up some handy global methods

--------------------------------------------------------------------------------
=end
require 'distro'
require 'hash_monkey_patch'
require 'instance'
require 'property_file_reader'
require 'running_tomcats'
require 'site'
require 'template_processor'
require 'tomcat'

module Kernel
  def bogus(message)
    puts(">>>>>>>>>>>>>BOGUS #{message}")
  end
end

$settings_file = ENV['HOME']+'/.instance-control.properties'
$instance = Instance.create($settings_file)
$all_tomcats = RunningTomcats.new()

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
