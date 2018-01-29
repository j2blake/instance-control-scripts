#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Show the state of the current instance, and what other Tomcats are running.

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'

def show_instance_info()
  puts "Instance:" 
  puts "   #{$instance.filename} -- #{$instance.props.description}"
end

def show_tomcat_status()
  puts $instance.tomcat.status_line
  RunningTomcats.new().summarize_except_for($instance.tomcat)
end

def show_distro_status()
  puts "Source: "
  puts $instance.distro.status
end

def show_kb_status()
  puts "Data: "
  puts "   #{$instance.knowledge_base}"
end

def separator()
  puts
  puts "------------------------------------------------------------"
  puts
end

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

separator()
show_instance_info()
puts
show_tomcat_status()
puts
show_distro_status()
puts
show_kb_status()
separator()
