=begin
--------------------------------------------------------------------------------

Limited information about a Vitro instance.

Info includes:
  - The path to the instance directory
  - A short name (from the instance.properties file in the directory)
  - A longer description (from the instance.properties file in the directory)
  - A status message. If the instance is valid, this is set to "OK". If not,
      this explains the problem.

--------------------------------------------------------------------------------
=end

module ICS
  OK_STATUS = "OK"
  class InstanceStub
    ENV_VAR = "VIVO_INSTANCES"
    attr_reader :path
    attr_reader :name
    attr_reader :description
    attr_reader :status
    def initialize(path, name, description, status = OK_STATUS)
      @path = path
      @name = name
      @description = description
      @status = status
    end

    def valid?
      return @status == OK_STATUS
    end

    #
    # Get:
    #   - a stub representing the current instance
    #   - an array of stubs representing available instances
    #   - an array of stubs representing invalid attempts at instances
    #
    def self.locate_instances
      raise UserInputError.new("No instance directories in $#{ENV_VAR}.") unless ENV.has_key?(ENV_VAR)

      settings = PropertyFileReader.read($settings_file)
      current_stub = create_stub(settings["instance_path"]);

      all_stubs = ENV[ENV_VAR].split(':').map { |path| create_stub(path) }

      return current_stub, all_stubs.select { |s| s.valid? }, all_stubs.select { |s| !s.valid? }
    end

    def self.create_stub(path)
      return InstanceStub.new("", "no name", "no path", "Path is nil.") unless path

      return InstanceStub.new(path, "no name", path, "Instance directory does not exist.") unless Dir.exist?(path)

      property_file = File.expand_path("instance.properties", path);
      return InstanceStub.new(path, "no name", path, "'instance.properties' file does not exist.") unless File.exist?(property_file)

      props = PropertyFileReader.read(property_file)
      name = props['name']
      return InstanceStub.new(path, "no name", path, "'instance.properties' contains no value for 'name'.") unless name

      description = props['description']
      return InstanceStub.new(path, name, path, "'instance.properties' contains no value for 'description'.") unless description

      return InstanceStub.new(path, name, description)
    end
  end
end