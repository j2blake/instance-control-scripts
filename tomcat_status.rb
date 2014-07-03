# Not independently executable

=begin
--------------------------------------------------------------------------------

Finds and encapsulates the status of the running Tomcat instances. Allows you
to ask about them.

When a path is provided, we need to dereference any symbolic links, because the 
real path is what will appear in the infos. This may throw an error.

--------------------------------------------------------------------------------
=end

require 'rexml/document'

class TomcatStatus
  attr_reader :infos

  # ------------------------------------------------------------------------------------
  private
  # ------------------------------------------------------------------------------------
  #
  # create an array of the paths of the running tomcats and their principal port numbers
  #
  def load_infos()
    @infos = []
    ps = `ps -ef | grep -e '-Dcatalina.home'`
    ps.split("\n").each() do |line|
      matches = /-Dcatalina.home=(\S+)/.match(line)
      if matches
        path = matches[1]
        port = find_tomcat_port(path)
        @infos << {:path => path, :port => port}
      end
    end
  end

  def find_tomcat_port(path)
    begin
      server_xml = File.expand_path('conf/server.xml', path)
      doc = REXML::Document.new(File.open(server_xml))
      doc.get_elements("Server/Service/Connector[@protocol='HTTP/1.1']").each do |e|
        return e.attribute('port').value()
      end
    rescue
      warning($!)
      "unknown"
    end
  end
  
  # ------------------------------------------------------------------------------------
  public
  # ------------------------------------------------------------------------------------

  def initialize()
    load_infos()
  end
  
  def which_port(path)
    real_path = Pathname.new(path).realpath.to_s
    @infos.each() do |info|
      return info[:port] if real_path == info[:path] 
    end
    nil
  end
  
  def other_than(path)
    begin
      real_path = Pathname.new(path).realpath.to_s
      return @infos.select() { |info| real_path != info[:path] }
    rescue
      return @infos
    end
  end

end
