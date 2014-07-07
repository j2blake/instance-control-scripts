=begin
--------------------------------------------------------------------------------

Info about this Tomcat

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end
require 'pathname'
require 'rexml/document'

class Tomcat
  attr_reader :props
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

  def shutting_down?
    lines = `tail -50 #{@path}/logs/catalina.out`
    lines.split("\n").reverse.each() do |line|
      if line.include?("A valid shutdown command was received")
        return true
      elsif line.include?("Starting ProtocolHandler")
        return false
      end
    end
    false
  end

  def status()
    if shutting_down?
      "Tomcat is running on port #{@port} (shutting down)"
    elsif running?
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

  def confirm()
    raise SettingsError.new("Tomcat directory '#{@path}' does not exist.") unless File.exist?(@path)
    raise SettingsError.new("Tomcat is not valid: unknown port") if $instance.tomcat.port == "unknown"
  end

  def initialize(path)
    @path = path
    @port = figure_port()
    @props = {"tomcat_path" => @path, "tomcat_port" => @port}
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
