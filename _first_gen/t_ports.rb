#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Change the port settings for the Tomcat of the current instance.

--------------------------------------------------------------------------------

Get the current port settings (how)? Offer options of 1-9. Modify server.xml (and setenv.sh) accordingly

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'

def show_current_ports()
  puts "Current tomcat ports: main=#{$instance.tomcat.port}, jpda=#{$instance.tomcat.jpda_port}"
  puts
end

def choose_port_range()
  puts "Enter port range from 1 to 9: "
  puts "     (for port based on 1080, 2080, etc.)"
  
  input = STDIN.gets.chomp
  @choice = input.to_i
  raise UserInputError.new("Invalid range: #{input}") unless (1..9).include?(@choice)
end

def save_choice()
  modify_server_xml()
  modify_setenv_sh()
end

def modify_server_xml()
  replace_in_file($instance.tomcat.file("conf/server.xml"), /"\d(\d\d\d)"/, "\"#{@choice}\\1\"")
  puts "modified ports in conf/server.xml"
end

def modify_setenv_sh()
  return unless $instance.tomcat.jpda_port.to_i > 0
  replace_in_file($instance.tomcat.file("bin/setenv.sh"), /JPDA_ADDRESS=\d(\d\d\d)/, "JPDA_ADDRESS=#{@choice}\\1")
  puts "modified JPDA port in bin/setenv.sh"
end

def replace_in_file(filename, regexp, replacement)
  raw_text = File.read(filename)
  File.open(filename, "w") do |file|
    file.puts(raw_text.gsub(regexp, replacement))
  end
end

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

begin
  show_current_ports()
  choose_port_range()
  save_choice()
rescue UserInputError
  puts "ERROR: #{$!}"
end
