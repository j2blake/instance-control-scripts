#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Show the state of the current instance, and what other Tomcats are running.

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../lib", File.expand_path(__FILE__))
require 'common'

def show_instance_info()
  puts "Instance:"
  puts "   #{@instance.name} -- #{@instance.description}"
end

def show_tomcat_status()
  my_tomcat = @instance.tomcat
  others = ICS::RunningTomcats.new.tomcats.reject { |tc| my_tomcat.matches(tc) }

  puts "Tomcat is %s\n   port %s, pid %s" % tomcat_status_strings(my_tomcat)

  if !others.empty?
    puts
    puts "Other tomcats:"
    others.each() do |other|
      puts "   %s\n      port %s, pid %s" % [other.path, other.port, other.pid]
    end
  end
end

def tomcat_status_strings(tomcat)
  case tomcat.state
  when :stopping
    ["running (shutting down)", tomcat.port, tomcat.pid]
  when :starting
    ["running (starting up)", tomcat.port, tomcat.pid]
  when :running
    ["running", tomcat.port, tomcat.pid]
  else
    ["not running", tomcat.port, "none"]
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

@instance = ICS::Instance::current_instance
separator()
show_instance_info()
puts
show_tomcat_status()
separator()
