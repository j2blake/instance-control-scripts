#! /usr/bin/ruby

=begin
--------------------------------------------------------------------------------

Erase the KnowledgeBase
--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'common'

#
# ---------------------------------------------------------
# MAIN ROUTINE
# ---------------------------------------------------------
#

begin
  raise UserInputError.new("Stop tomcat first.") if $instance.tomcat.running?

  begin
    $instance.knowledge_base.confirm
  rescue SettingsError
    puts "Knowledge base does not exist: #{$instance.knowledge_base}."
    puts "Create it? (y/n)"
    raise UserInputError.new("OK") unless gets.chomp == 'y'
  end
  
  $instance.knowledge_base.erase
  $instance.knowledge_base.create
rescue SettingsError
  puts
  puts $!
  puts
rescue UserInputError
  puts
  puts $!
  puts
end