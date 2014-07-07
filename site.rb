=begin
--------------------------------------------------------------------------------

Info about this Site

--------------------------------------------------------------------------------
=end

class Site
  attr_reader :path
  attr_reader :props
  
  def initialize(path)
    @props = PropertyFileReader.read(File.expand_path('site.properties', path))
  end
  
  def self.create(path)
    Site.new(path)
  end
end