# Not independently executable

=begin
--------------------------------------------------------------------------------

Info about the source code distribution.
Is it git repositories or a release?
Is it older than release 1.5?

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

class Distro
  # ------------------------------------------------------------------------------------
  private
  # ------------------------------------------------------------------------------------
  #
  def confirm_path()
    throw SettingsError.new("Distribution directory doesn't exist: '#{@path}'") unless File.exist?(@path)
    throw SettingsError.new("Distribution 'directory' is not a directory: '#{@path}'") unless Dir.exist?(@path)
  end

  def check_for_release()
    release_dir = find_release_dir()
    return unless release_dir
    
    @is_release = true
    @vivo_path = release_dir
    @vitro_path = File.expand_path('vitro-core', release_dir)
    throw SettingsError.new("Can't find 'vitro-core' in '#{@path}'") unless File.exist?(@vitro_path)
    @release_info = File.basename(release_dir)
  end

  def find_release_dir()
    Dir.foreach(@path) do |filename|
      if (filename.start_with?('vivo-rel-'))
        return File.expand_path(filename, @path)
      end
    end
  end
  
  def check_for_git
    return if @is_release
    
    @is_release = false
    @vivo_path = File.expand_path('VIVO', @path)
    throw SettingsError.new("Can't find 'VIVO' working copy in '#{@path}'") unless File.exist?(@vivo_path)
    @vitro_path = File.expand_path('Vitro', @path)
    throw SettingsError.new("Can't find 'Vitro' working copy in '#{@path}'") unless File.exist?(@vitro_path)
    @release_info = "Working copy"
  end
  
  def check_is_old()
    @is_before_1_5 = !File.exist?(File.expand_path('build.properties.example', @vivo_path))
  end

  # ------------------------------------------------------------------------------------
  public
  # ------------------------------------------------------------------------------------

  attr_reader :path
  attr_reader :vivo_path
  attr_reader :vitro_path
  attr_reader :is_release
  attr_reader :is_before_1_5
  attr_reader :release_info

  def initialize(path)
    @path = path
    confirm_path()
    check_for_release()
    check_for_git()
    check_is_old()
    raise SettingsError.new("Distribution directory must contain a release or repositories: #{@path}") unless @vivo_path
  end
  
  def file(filename)
    File.expand_path(filename, @path)
  end

end

