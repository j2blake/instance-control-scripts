=begin
--------------------------------------------------------------------------------

Info about this VIVO instance

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

class Instance
  attr_reader :path
  attr_reader :filename
  attr_reader :description
  attr_reader :distro
  attr_reader :tomcat
  attr_reader :props
  attr_reader :all_props
  def file(filename)
    File.expand_path(filename, @path)
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

    @all_props = @distro.props.merge(@tomcat.props).merge(@site.props).merge(@props)
  end

  def self.create(settings_file)
    settings = PropertyFileReader.read(settings_file)
    if (settings.instance_path)
      Instance.new(settings.instance_path)
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
