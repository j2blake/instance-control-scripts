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

def figure_startup_command
  bin_dir = File.expand_path("bin", @instance.tomcat.path)
  return "#{bin_dir}/startup.sh" if File.exist?("#{bin_dir}/startup.sh")
  return "#{bin_dir}/catalina.sh start" if File.exist?("#{bin_dir}/catalina.sh")
  raise "Can't find the startup script in #{bin_dir}"
end

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

  puts `#{figure_startup_command}`
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