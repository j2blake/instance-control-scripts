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
    state != :stopped
  end

  def status_line()
    case state()
    when :stopping
      "Tomcat is running on port #{@port} (shutting down)"
    when :starting
      "Tomcat is running on port #{@port} (starting up)"
    when :running
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

  def state()
    return :stopped unless RunningTomcats.new().is_running(self)

    log_file = File.expand_path('logs/catalina.out', @path)
    return :running unless File.exist?(log_file)

    File.readlines(log_file).reverse_each do |line|
      if line.include?("A valid shutdown command was received")
        return :stopping
      elsif line.include?("Initializing ProtocolHandler") ||
               # if we don't recognize anything since the last shutdown, we are starting.
               line.include?("Destroying ProtocolHandler")
        return :starting
      elsif line.include?("Server startup in ")
        return :running
      end
    end
    return :running
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
