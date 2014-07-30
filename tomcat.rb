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
  attr_reader :pid
  attr_reader :port
  attr_reader :jpda_port
  attr_reader :max_heap
  
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

  def figure_jpda_port()
    setenv_file = File.expand_path('bin/setenv.sh', @path)
    return 'none' unless File.exist?(setenv_file)
    return 'none' unless /JPDA_ADDRESS=(\S+)/ =~ File.read(setenv_file)
    return $1
  end

  def figure_max_heap()
    setenv_file = File.expand_path('bin/setenv.sh', @path)
    return 'default' unless File.exist?(setenv_file)
    return 'default' unless /-Xmx(\S+)/ =~ File.read(setenv_file)
    return $1
  end

  def set_props()
    @props = {"tomcat_path" => @path, "tomcat_port" => @port, "tomcat_pid" => @pid, "tomcat_jpda_port" => @jpda_port, "tomcat_max_heap" => @max_heap}
  end

  def running?
    state != :stopped
  end

  def status_line()
    case state()
    when :stopping
      "Tomcat is running (shutting down)\n   port #{@port}, pid #{get_pid()}, jpda #{@jpda_port}, -Xmx #{@max_heap}"
    when :starting
      "Tomcat is running (starting up)\n   port #{@port}, pid #{get_pid()}, jpda #{@jpda_port}, -Xmx #{@max_heap}"
    when :running
      "Tomcat is running\n   port #{@port}, pid #{get_pid()}, jpda #{@jpda_port}, -Xmx #{@max_heap}"
    else
      "Tomcat is not running\n   port #{@port}, jpda #{@jpda_port}, -Xmx #{@max_heap}"
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
  
  def get_pid()
    RunningTomcats.new().get_pid(self) || "0"
  end

  def confirm()
    raise SettingsError.new("Tomcat directory '#{@path}' does not exist.") unless File.exist?(@path)
    raise SettingsError.new("Tomcat is not valid: unknown port") if $instance.tomcat.port == "unknown"
  end

  def initialize(path, pid)
    @path = path
    @pid = pid
    @port = figure_port()
    @jpda_port = figure_jpda_port()
    @max_heap = figure_max_heap()
    @props = set_props()
  end

  def self.create(path)
    if path
      Tomcat.new(path, "0")
    else
      EmptyTomcat.new()
    end
  end
end

class EmptyTomcat < Tomcat
  def status_line()
    "Tomcat is not defined."
  end

  def initialize()
    @path = 'no current instance'
    @pid = "0"
    @port = 'unknown'
    @jpda_port = 'unknown'
    @max_heap = 'unknown'
    @props = set_props()
  end
end
