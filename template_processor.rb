=begin
--------------------------------------------------------------------------------

A utility class that reads a template file and replaces the key strings in it.

Each key string should look something like this:
    <%= @settings.root_user %>

This class will accept a hash of settings and make them available to the template.

process() does the substitution as above
process_complete() does the substitution and complains about any keys for which
   values were not found.
--------------------------------------------------------------------------------
=end
require 'erb'

#
# The main class
#
class TemplateProcessor
  def process_string(raw)
    ERB.new(raw).result(binding)
  end

  #
  # Process the source file and either return the result,
  # or write it to a target file.
  #
  def process(source, target=nil)
    raise SettingsError.new("#{source} doesn't exist") unless File.exist?(source)

    if target
      File.open(source) do |source_file|
        File.open(target, 'w') do |target_file|
          target_file.write(process_string(source_file.read()))
        end
      end
    else
      File.open(source) do |source_file|
        process_string(source_file.read())
      end
    end
  end

  #
  # Check to insure that all keys have defined values before processing
  #
  def process_complete(source, target)
    missing = list_required_keys(source) - @settings.keys.map() {|k| "@settings.#{k}"}
    raise SettingsError.new("Missing values for these keys: #{missing}") unless missing.empty?
    process(source, target)
  end

  def list_required_keys(source)
    # Look for <%= name %>
    matches = []
    File.open(source) do |source_file|
      source_file.each do |line|
        matches << line.scan(/<%=\s*([^%\s]+)\s*%>/)
      end
    end
    return matches.flatten().sort.uniq
  end

  def initialize(props)
    @settings = props
  end

end
