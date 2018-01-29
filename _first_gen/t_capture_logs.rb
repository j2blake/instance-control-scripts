#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Make a copy of the Tomcat logs in a time-stamped subdirectory of the instance
directory.

--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'
require 'date'


def figure_time_stamp()
  return DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")
end

def logs_dir()
  "#{$instance.tomcat.path}/logs"
end

def confirm_logs_exist()
  log_files = Dir.entries(logs_dir).delete_if() {|fn| fn.start_with?(".")}
  raise UserInputError.new("There are no Tomcat logs") if log_files.empty?
end

def create_dir
  tomcat_logs_dir = $instance.file('logs')
  Dir.mkdir(tomcat_logs_dir) unless File.directory?(tomcat_logs_dir)

  @this_logs_dir = File.expand_path("Tomcat_#{figure_time_stamp}", tomcat_logs_dir)
  Dir.mkdir(@this_logs_dir)
end

def copy_logs()
  Dir.chdir(@this_logs_dir) do
    system("cp #{logs_dir}/* .")
  end
end

def add_read_me()
  puts "Add a comment for the README.txt file"
  comment = STDIN.gets.strip
  return if comment.empty?

  Dir.chdir(@this_logs_dir) do
    File.open('README.txt', "w") do |file|
      file.puts comment
    end
  end
end

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

begin
  $instance.tomcat.confirm
  confirm_logs_exist
  create_dir
  copy_logs
  add_read_me
rescue SettingsError
  puts
  puts $!
  puts
rescue UserInputError
  puts
  puts $!
  puts
end