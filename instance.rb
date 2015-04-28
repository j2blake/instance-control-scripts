=begin
--------------------------------------------------------------------------------

Info about this VIVO instance

Create using factory methods:
   Instance.from_settings_file(settings_file)
   Instance.from_instance_path(instance_path)

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

class Instance
  attr_reader :path
  attr_reader :filename
  attr_reader :distro
  attr_reader :tomcat
  attr_reader :knowledge_base
  attr_reader :props
  attr_reader :all_props
  def file(filename)
    File.expand_path(filename, @path)
  end
  
  # Get a file from the distro, unless overridden in the instance.
  def distro_file(filename)
    if File.exist?(file(filename))
      file(filename)
    else
      @distro.file(filename)
    end
  end

  def initialize(path)
    @path = path
    @filename = File.basename(path)

    @props = {
      'description' => '(no description)',
      'site_home' => @path,
      'distro_home' => @path,
      'tomcat_home' => file('tomcat'),
      'vivo_home' => file('vivo_home')
    }
    @props.merge!(PropertyFileReader.read(file('instance.properties')))

    @site = Site.create(@props.site_home)
    @distro = Distro.create(@props.distro_home)
    @tomcat = Tomcat.create(@props.tomcat_home)
    @knowledge_base = KnowledgeBase.create(@props)

    @all_props = @distro.props.merge(@tomcat.props).merge(@site.props).merge(@props)
  end

  def self.from_settings_file(settings_file)
    settings = PropertyFileReader.read(settings_file)
    self.from_instance_path(settings.instance_path);
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
    @path = 'no current instance'
    @filename = 'no filename'
    @description = '(no description)'
    @tomcat = EmptyTomcat.new()
  end
end
