#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Choose an instance from among the ~/Testing/instances/* directories, and
record that choice.

--------------------------------------------------------------------------------

To be eligible, a directory must include a instance.properties file. Display a
list of ineligible directories along with the eligible ones.

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'

class InstanceStub
  attr_reader :filename
  attr_reader :path
  attr_reader :description
  def initialize(filename, path, description)
    @filename = filename
    @path = path
    @description = description
  end
end

# Find out what instances we have available
def locate_instances()
  instances_dir = ENV['HOME']+'/Testing/instances'

  @instances = []
  @invalid = []

  Dir.entries(instances_dir).sort().each() do |filename|
    next if filename.start_with?(".")

    path = File.expand_path(filename, instances_dir)
    props_file = File.expand_path('instance.properties', path)
    if File.exist?(props_file)
      props = PropertyFileReader.read(props_file)
      description = props.description || "(no description)"
      @instances.push(InstanceStub.new(filename, path, description))
    else
      @invalid.push(filename)
    end
  end
end

def choose_instance()
  if (!@invalid.empty?)
    puts
    puts "Ignored invalid directories: "
    puts "     #{@invalid.join(', ')}"
  end

  puts
  puts "Enter instance number: "
  @instances.each_index do |index|
    instance = @instances[index]
    puts "  #{index+1} = #{instance.filename} -- #{instance.description}"
  end

  input = STDIN.gets.chomp
  @choice = input.to_i
  if @choice <= 0 || @choice > @instances.length
    raise UserInputError.new("Invalid index: #{input}")
  end
end

def save_choice()
  full_instance = Instance.from_instance_path(@instances[@choice-1].path)
  
  File.open($settings_file, "w") do |file|
    file.puts("# The currently seleted instance")
    file.puts("instance_path = #{full_instance.path}")
    file.puts("logs_path = #{full_instance.tomcat.path}/logs")
    file.puts("home_path = #{full_instance.props.vivo_home}")
  end
  puts "instance set to '#{full_instance.filename}'"
end

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

locate_instances()

begin
  choose_instance()
  save_choice()
rescue UserInputError
  puts "ERROR: #{$!}"
end
