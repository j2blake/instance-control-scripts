=begin
--------------------------------------------------------------------------------

Info about this Tomcat

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end
require 'pathname'
require 'rexml/document'

class Tomcat
  attr_reader :path
  attr_reader :port
  def file(filename)
    return File.expand_path(filename, @path)
  end

  def figure_port()
    begin
      doc = REXML::Document.new(File.open(file('conf/server.xml')))
      doc.get_elements("Server/Service/Connector[@protocol='HTTP/1.1']").each do |e|
        return e.attribute('port').value()
      end
    rescue
      puts $!
    end
    'unknown'
  end
  
  def running?
    $all_tomcats.is_running(self)
  end

  def status()
    if running?
      "Tomcat is running on port #{@port}"
    else
      "Tomcat is not running (#{@port})"
    end
  end

  def matches(other)
    if other.path == @path
      true
    else
      begin
        other.path == Pathname.new(@path).realpath.to_s
      rescue
        false
      end
    end
  end

  def initialize(path)
    @path = path
    @port = figure_port()
  end
  
  def self.create(path)
    if path
      Tomcat.new(path)
    else
      EmptyTomcat.new()
    end
  end
end

class EmptyTomcat < Tomcat
  def status()
    "Tomcat is not defined."
  end

  def initialize()
    @path = 'no current instance'
    @port = 'unknown'
  end
end
