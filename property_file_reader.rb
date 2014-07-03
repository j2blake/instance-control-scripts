=begin
--------------------------------------------------------------------------------

A utility class that reads a properties file and returns a hash containing the
properties.

--------------------------------------------------------------------------------
=end

class FunkyHash
  def self.create()
    hash = {}

    def hash.method_missing method_id, *args
      if args.empty?
        self[method_id.to_s]
      elsif method_id.to_s.end_with?('=')
        self[method_id.to_s.chop] = args[0]
      else
        super
      end
    end

    hash
  end
end

class PropertyFileReader
  # Read a properties file and return a hash.
  #
  # Parameters: the path to the properties file
  #
  # The hash includes the special property "properties_file_path", which holds
  # the path to the properties file.
  #
  def self.read(file_path)
    properties = FunkyHash.create
    properties["properties_file_path"] = File.expand_path(file_path)

    if File.exist?(file_path)
      File.open(file_path) do |file|
        file.each_line do |line|
          line.strip!
          if line.length == 0 || line[0] == ?# || line[0] == ?!
            # ignore blank lines, and lines starting with '#' or '!'.
          elsif line =~ /(.*?)\s*[=:]\s*(.*)/
            # key and value are separated by '=' or ':' and optional whitespace.
            properties[$1.strip] = $2
          else
            # No '=' or ':' means that the value is empty.
            properties[line] = ''
          end
        end
      end
    end

    return properties
  end
end
