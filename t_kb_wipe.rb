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
  $instance.knowledge_base.confirm
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