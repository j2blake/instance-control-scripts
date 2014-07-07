#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Deploy VIVO, if Tomcat isn't running.

Don't just run the build script. Also process the templates for build.properties
and runtime.properties

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
  $instance.distro.deploy($instance.all_props)
rescue SettingsError
  puts
  puts $!
  puts
rescue UserInputError
  puts
  puts $!
  puts
end