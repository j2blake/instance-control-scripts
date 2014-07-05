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

#
# Members of this hash can be accessed using dot-notation.
#
class HandyHash < Hash
  @props = {}

  def method_missing method_id, *args
    if args.empty?
      @props[method_id.to_s]
    else
      super
    end
  end
end

#
# The main class
#
class TemplateProcessor
  #
  # Process the source file and either return the result,
  # or write it to a target file.
  #
  def self.process(props, source, target=nil)
    raise SettingsError.new("#{source} doesn't exist") unless File.exist?(source)
    @settings = HandyHash.new().merge!(props);

    if target
      File.open(source) do |source_file|
        File.open(target, 'w') do |target_file|
          raw = source_file.read()
          cooked = ERB.new(raw).result
          target_file.write(cooked)
        end
      end
    else
      File.open(source) do |source_file|
        raw = source_file.read()
        cooked = ERB.new(raw).result
      end
    end
  end
  
  def self.process_complete(props, source, target=nil)
    missing = list_required_keys(source) - props.keys
    raise SettingsError.new("Missing these keys: #{missing}") unless missing.empty?
    process(props, source, target) 
  end
  
  def self.list_required_keys(source)
    bogus("Totally bogus list_required_keys")
    []
  end
end
