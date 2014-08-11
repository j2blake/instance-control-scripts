#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Show the state of the current instance, and what other Tomcats are running.

--------------------------------------------------------------------------------

Eventually, we want a display like this:

  ------------------------------------------------
  develop -- The develop instance
  ------------------------------------------------
  Tomcat: running                (not running, starting up, shutting down)
    port 8080, jpda 4000, process 12344, -Xmx 2046m                 (default)
  Other Tomcats:
    /Users/jeb228/Testing/instances/florida-to-1.6.3/tomcat
      port 8080, jpda 6040, process 20983, -Xmx 1029m
  -------------------------------------------------
  Source status:
    Vitro:
    Vivo:
    [or is distribution vivo-rel-1.6.2]
  -------------------------------------------------

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'
require 'pathname'

def show_instance_info()
  separator()
  puts "#{$instance.filename} -- #{$instance.props.description}"
end

def show_tomcat_status()
  separator()
  puts $instance.tomcat.status_line
  RunningTomcats.new().summarize_except_for($instance.tomcat)
end

def show_distro_status()
  separator()
  puts $instance.distro.status
end

def show_kb_status()
  separator()
  puts "Knowledge base: \n   #{$instance.knowledge_base}"
end

def separator()
  puts "------------------------------------------------------------"
end

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

show_instance_info()
show_tomcat_status()
show_distro_status()
show_kb_status()
separator()
puts
