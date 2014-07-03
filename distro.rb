=begin
--------------------------------------------------------------------------------

Info about the source code distribution.
Is it git repositories or a release?
Is it older than release 1.5?

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

class Distro
  attr_reader :path
  attr_reader :props
  def file(filename)
    File.expand_path(filename, @path)
  end

  def initialize(path)
    @path = path
    @props = PropertyFileReader.read(file('distro.properties'))
    @props.merge!(default_paths()) {|k, v1, v2| v1}
  end

  def self.create(path)
    distro = ReleaseDistro.new(path)
    if !distro.valid?
      distro = GitDistro.new(path)
      if !distro.valid?
        distro = EmptyDistro.new(path)
      end
    end
    return distro
  end
end

class ReleaseDistro < Distro
  def valid?
    @filename != 'bogus'
  end

  def default_paths()
    {"vitro_path" => file(@filename), "vivo_path" => file(@filename + '/vitro-core')}
  end

  def status()
    "Source status: Released distribution: #{@filename}"
  end

  def initialize(path)
    @filename = 'bogus'
    Dir.foreach(path) do |filename|
      if (filename.start_with?('vivo-rel-'))
        @filename = filename
      end
    end
    
    super
  end
end

class GitDistro < Distro
  def valid?
    File.exist?(@props.vitro_path) && File.exist?(@props.vivo_path)
  end

  def default_paths()
    {"vitro_path" => file('Vitro'), "vivo_path" => file('VIVO')}
  end

  def status()
    puts "git status:"
    puts "    VIVO:"
    Dir.chdir(@props.vivo_path) { format_git_status(`git status`) }
    puts "    Vitro:"
    Dir.chdir(@props.vitro_path) { format_git_status(`git status`) }
  end
end

class EmptyDistro < Distro
  def default_paths()
    {}
  end
  
  def status()
    "Not a valid distribution: #{@path}"
  end

  def initialize(path)
    super
  end
end