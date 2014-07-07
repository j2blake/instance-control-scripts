#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Stop Tomcat, if it's running.

Then wait for a second and check the log to see whether it received the shutdown
command.

If so, then wait for up to 5 more seconds to let it stop. If it doesn't, then complain.

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
  raise UserInputError.new("Tomcat is not running.") unless $instance.tomcat.running?

  system("#{$instance.tomcat.path}/bin/catalina.sh stop")

  raise SettingsError.new("Tomcat did not receive the shutdown command") unless $instance.tomcat.shutting_down?

  5.times do |i|
    sleep(1)
    if ! $instance.tomcat.running?
      return puts("Shut down.")
    end
    puts i+1
  end
  
  raise SettingsError.new("Tomcat has not shut down");
rescue SettingsError
  puts
  puts $!
  puts
rescue UserInputError
  puts
  puts $!
  puts
end