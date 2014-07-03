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
  puts $all_tomcats.summarize_except_for($instance.tomcat)
end

def show_distro_status()
  separator
  puts $instance.distro.status
end

def show_release_status()
  separator()
end

def show_git_status()
  separator()
  puts "git status:"
  puts "    VIVO:"
  Dir.chdir(@distro.vivo_path) { format_git_status(`git status`) }
  puts "    Vitro:"
  Dir.chdir(@distro.vitro_path) { format_git_status(`git status`) }
end

def format_git_status(text)
  puts "        #{text.split("\n").join("\n        ")}"
end

def figure_tomcat_status()
  return "Tomcat is not defined." unless $settings.catalina_home
  begin
    port = @tomcats.which_port($settings.catalina_home)
    return "Tomcat is not running" unless port
    return "Tomcat is running on port #{port}"
  rescue
    return "No Tomcat at #{$settings.catalina_home}"
  end
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
