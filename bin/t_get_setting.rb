#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Create an Instance based on the settings file, and return a value from it.

So we can change to the VIVO home directory of the current instance by creating 
an alias like this:
    alias t_cd_home="cd \`t_get_setting.rb instance.vivo_home\`"

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../lib", File.expand_path(__FILE__))
require 'common'

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

instance = ICS::Instance::current_instance
puts eval(ARGV[0])