#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Erase the Tomcat logs, unless Tomcat is running

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
  raise UserInputError.new("Stop tomcat first.") if $instance.tomcat.running?
  system("rm #{$instance.tomcat.path}/logs/*")
rescue SettingsError
  puts
  puts $!
  puts
rescue UserInputError
  puts
  puts $!
  puts
end