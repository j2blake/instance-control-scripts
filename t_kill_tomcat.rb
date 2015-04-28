#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Stop Tomcat, if it's running, with a kill command.

Wait for up to 5 more seconds to let it stop. If it doesn't, then complain.

Presumably, you would do this after t_stop_tomcat.rb failed.

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

  system("kill -9 #{$instance.tomcat.pid}")

  puts "Sent kill -9 #{$instance.tomcat.pid}"

  4.times do |i|
    break unless $instance.tomcat.running?
    puts i+1
    sleep(1)
  end
  
  raise SettingsError.new("Tomcat has not shut down") if $instance.tomcat.running?
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