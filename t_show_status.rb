#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Show the state of the current instance, and what other Tomcats are running.

--------------------------------------------------------------------------------

Eventually, we want a display like this:

    current instance: develop (The develop instance)
    git status:
        Vitro:
        Vivo:
    [or is distribution vivo-rel-1.6.2]
    tomcat is [not] running.
    Other tomcats:
        port xxxx, /other/path/to/tomcat

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'
require 'pathname'

def show_instance_info()
  separator()
  puts "current instance: #{$instance.filename} -- #{$instance.description}"
end

def show_tomcat_status()
  separator()
  puts $instance.tomcat.status
  $all_tomcats.summarize_except_for($instance.tomcat)
end

def show_distro_status()
  separator
  puts $instance.distro.status
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

show_instance_info()
show_tomcat_status()
show_distro_status()
