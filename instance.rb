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
  def file(filename)
    File.expand_path(filename, @path)
  end

  def initialize(path)
    @path = path
    @filename = File.basename(path)
    @props = PropertyFileReader.read(file('instance.properties'))
    @description = @props.description || '(no description)'
    @distro = Distro.create(@props.distro_home || @path)
    @tomcat = Tomcat.create(@props.tomcat_home || file('tomcat'))
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
