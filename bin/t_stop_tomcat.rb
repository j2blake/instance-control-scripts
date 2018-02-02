#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Stop Tomcat, if it's running.

Wait for two seconds and check the log to see whether it received the shutdown
command.

Wait up to 5 more seconds to let it stop. If it doesn't, then complain.

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
  raise UserInputError.new("Tomcat is not running.") unless @instance.tomcat.running?

  system("#{@instance.tomcat.path}/bin/catalina.sh stop")

  sleep(2)
  raise SettingsError.new("Tomcat did not receive the shutdown command") unless [:stopped, :stopping].include?(@instance.tomcat.state)

  4.times do |i|
    break unless @instance.tomcat.running?
    puts i+1
    sleep(1)
  end
  
  raise SettingsError.new("Tomcat has not shut down") if @instance.tomcat.running?
  puts("Shut down.")  
rescue SettingsError
  puts
  puts $!
  puts
rescue UserInputError
  puts
  puts $!
  puts
end