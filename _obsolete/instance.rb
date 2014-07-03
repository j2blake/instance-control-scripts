# Not independently executable

=begin
--------------------------------------------------------------------------------

Info about this VIVO instance

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

class Instance
  # ------------------------------------------------------------------------------------
  private
  # ------------------------------------------------------------------------------------
  #
  def confirm_path()
    throw SettingsError.new("Instance directory doesn't exist: '#{@path}'") unless File.exist?(@path)
    throw SettingsError.new("Instance 'directory' is not a directory: '#{@path}'") unless Dir.exist?(@path)
  end

  # ------------------------------------------------------------------------------------
  public
  # ------------------------------------------------------------------------------------

  attr_reader :path

  def initialize(path)
    @path = path
    confirm_path(path)
  end
  
  def file(filename)
    File.expand_path(filename, @path)
  end

end
