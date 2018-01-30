=begin
--------------------------------------------------------------------------------

Info about this VIVO instance

Create using factory methods:
   Instance.from_settings_file(settings_file)
   Instance.from_instance_path(instance_path)

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

module ICS
  class Instance
    attr_reader :path
    attr_reader :name
    attr_reader :description
    attr_reader :status
    attr_reader :tomcat
    attr_reader :vivo_home
    def valid?
      return @status == OK_STATUS
    end

    def file(filename)
      File.expand_path(filename, @path)
    end

    def initialize(path)
      @path = path

      props = {
        'name'=> '(no name)',
        'description' => '(no description)',
        'tomcat_home' => file('tomcat'),
        'vivo_home' => file('vivo_home')
      }
      props.merge!(PropertyFileReader.read(file('instance.properties')))

      @name = props['name']
      @description = props['description']
      @tomcat = ICS::Tomcat::create(props['tomcat_home'])
      @vivo_home = props['vivo_home']

      @status = OK_STATUS
    end

    def self.current_instance
      settings = PropertyFileReader.read($settings_file)
      from_instance_path(settings['instance_path']);
    end

    def self.from_instance_path(instance_path)
      if (instance_path)
        Instance.new(instance_path)
      else
        EmptyInstance.new()
      end
    end
  end

  class EmptyInstance < Instance
    def initialize()
      @path = '/no_current_instance'
      @name = '(no name)'
      @description = '(no description)'
      @tomcat = ICS::EmptyTomcat.new()
      @vivo_home = '/no_vivo_home'
    end
  end
end