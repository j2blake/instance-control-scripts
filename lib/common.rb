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
require 'rexml/document'
require 'instance'
require 'instance_stub'
require 'property_file_reader'
require 'running_tomcats'
require 'tomcat'

#require 'distro'
#require 'hash_monkey_patch'
#require 'knowledge_base'
#require 'property_file_reader'
#require 'running_tomcats'
#require 'site'
#require 'template_processor'
#require 'tomcat'

$settings_file = File.expand_path('.instance-control.properties', ENV['HOME'])
$config_root = File.expand_path(File.join('Development/InstanceControlScripts/projects/instance-control-scripts', 'config'), ENV['HOME'])
  
$defaults = {
  'distro' => 'vivo_post_1.9'
}

def load_plugins(category, choice)
  category_dir = File.join($config_root, category)
  choice_dir = File.join(category_dir, choice)
  plugins_file = File.join(choice_dir, category + "_plugins.rb")
  
  if !Dir.exist?(category_dir)
    warning("Config directory '#{category_dir}' does not exist.")
  elsif !Dir.exist?(choice_dir)
    warning("Config directory '#{choice_dir}' does not exist.")
  elsif File.exist?(plugins_file)
    load plugins_file
  end

end
