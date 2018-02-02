#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Choose an instance from among those registered in the VIVO_INSTANCES environment
variable, and record that choice.

Display a list of ineligible directories along with the eligible ones. A 
directory might be ineligible for a variety of reasons: for example, missing an 
instance.properties file.

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../lib", File.expand_path(__FILE__))
require 'common'

def choose_instance()
  puts
  if (@current.path.empty?)
    puts "There is no current instance"
  elsif @current.valid?
  puts "Current instance is: #{@current.name} -- #{@current.description}"
  else
    puts "Current instance is not valid: #{@current.path}" 
    puts "  INVALID:  #{@current.name} -- #{@current.description}"
    puts "        -- #{@current.status}"
  end
  
  if (!@invalid.empty?)
    puts
    puts "Invalid directories: "
    @invalid.each do |inv|
      puts "  INVALID:  #{inv.name} -- #{inv.description}"
      puts "        -- #{inv.status}"
    end
  end

  puts
  puts "Enter instance number: "
  @stubs.each_index do |index|
    stub = @stubs[index]
    puts "  #{index + 1} = #{stub.name} -- #{stub.description}"
  end

  input = STDIN.gets.chomp
  choice = input.to_i
  if choice <= 0 || choice > @stubs.length
    raise UserInputError.new("Invalid index: '#{input}'")
  end
  
  @chosen = ICS::Instance.new(@stubs[choice - 1].path)
end

def save_choice()
  File.open($settings_file, "w") do |file|
    file.puts("# The currently seleted instance")
    file.puts("instance_path = #{@chosen.path}")
  end
  
  puts
  puts "instance set to '#{@chosen.name}'"
end

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

@current, @stubs, @invalid = ICS::InstanceStub::locate_instances()

begin
  choose_instance()
  save_choice()
rescue UserInputError
  puts "ERROR: #{$!}"
end