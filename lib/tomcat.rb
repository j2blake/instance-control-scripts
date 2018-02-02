=begin
--------------------------------------------------------------------------------

Info about this Tomcat instance

--------------------------------------------------------------------------------
=end

module ICS
  class Tomcat
    attr_reader :path
    attr_reader :pid
    attr_reader :port
    def figure_pid()
      RunningTomcats.new().get_pid(self) || "0"
    end

    def figure_port()
      begin
        doc = REXML::Document.new(File.open(File.expand_path('conf/server.xml', @path)))
        doc.get_elements("Server/Service/Connector[@protocol='HTTP/1.1']").each do |e|
          return e.attribute('port').value()
        end
      rescue
        puts "WARNING: #{$!}"
      end
      'unknown'
    end

    def initialize(path, pid = nil)
      @path = path
      @pid = pid || figure_pid()
      @port = figure_port()
    end

    def state()
      return :stopped unless ICS::RunningTomcats.new.is_running(self)

      log_file = File.expand_path('logs/catalina.out', @path)
      return :running unless File.exist?(log_file)

      File.readlines(log_file).reverse_each do |line|
        if line.include?("A valid shutdown command was received")
          return :stopping
        elsif line.include?("Initializing ProtocolHandler") || line.include?("Destroying ProtocolHandler")
          return :starting
        elsif line.include?("Server startup in ")
          return :running
        end
      end
      return :running
    end

    def matches(other)
      return true if other.path == @path
      begin
        return other.path == Pathname.new(@path).realpath.to_s
      rescue
        return false
      end
    end

    def self.create(tomcat_home)
      return Tomcat.new(tomcat_home)
    end
  end

  class EmptyTomcat < Tomcat
    def initialize()
      @path = 'no current instance'
      @pid = "0"
    end
  end

end