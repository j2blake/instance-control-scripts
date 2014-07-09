#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Start Tomcat, if:
  it isn't running
  it wouldn't collide with another Tomcat
  the most recent deploy was successful.

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

begin
  $instance.tomcat.confirm
  raise UserInputError.new("Tomcat is already running.") if $instance.tomcat.running?
  
  port = $instance.tomcat.port
  raise UserInputError.new("Port #{port} is already in use") if RunningTomcats.new().in_use?(port)
  
  props = PropertyFileReader.read("#{$instance.file('_successful')}")
  raise UserInputError.new("Previous build failed.") unless props.deploy_success
  
  puts `#{$instance.tomcat.path}/bin/catalina.sh jpda start`
  code = $?.exitstatus || 0
  puts "Exited with code #{code}" unless code == 0
rescue SettingsError
  puts
  puts $!
  puts
rescue UserInputError
  puts
  puts $!
  puts
end