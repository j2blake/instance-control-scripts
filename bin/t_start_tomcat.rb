#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Start Tomcat, if:
  it's a valid Tomcat
  it isn't running
  it wouldn't collide with another Tomcat

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../lib", File.expand_path(__FILE__))
require 'common'

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

begin
  @instance = ICS::Instance::current_instance

  @instance.tomcat.confirm

  raise UserInputError.new("Tomcat is already running.") if @instance.tomcat.running?
  
  port = @instance.tomcat.port
  raise UserInputError.new("Port #{port} is already in use") if ICS::RunningTomcats.new().in_use?(port)
  
  puts `#{@instance.tomcat.path}/bin/catalina.sh start`
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