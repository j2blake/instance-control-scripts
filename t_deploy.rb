#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Deploy VIVO, if Tomcat isn't running.

Don't just run the build script. Also process the templates for build.properties
and runtime.properties

If the build fails, write that down. We won't want to run until its fixed.

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'

def record_result(success)
  Dir.mkdir($instance.file('_generated')) unless Dir.exist?($instance.file('_generated'))
  File.open("#{$instance.file('_generated/successful')}", "w") do |file|
    file.puts("deploy_success = #{success}")
  end
end

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

begin
  $instance.tomcat.confirm
  $instance.distro.deploy($instance.all_props)
  record_result(true)
rescue SettingsError
  puts
  puts $!
  puts
  record_result(false)
rescue UserInputError
  puts
  puts $!
  puts
end