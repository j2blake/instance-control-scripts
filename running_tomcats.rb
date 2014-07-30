=begin
--------------------------------------------------------------------------------

A utility class that finds out what other tomcats are running. 

--------------------------------------------------------------------------------
=end

class RunningTomcats
  attr_reader :tomcats
  
  def is_running(my_tomcat)
    @tomcats.each() do |tc|
      if my_tomcat.matches(tc)
        return true
      end 
    end
    false
  end

  def get_pid(my_tomcat)
    @tomcats.each() do |tc|
      if my_tomcat.matches(tc)
        return tc.pid
      end 
    end
    false
  end

  def summarize_except_for(my_tomcat)
    others = tomcats.select() {|tc| !my_tomcat.matches(tc) }
    if !others.empty?
      puts
      puts "Other tomcats:"
      others.each() do |other|
        puts "   #{other.path}\n      port #{other.port}, pid #{other.pid}, jpda #{other.jpda_port}, -Xmx #{other.max_heap}"
      end
    end
  end
  
  def in_use?(port)
    @tomcats.each() do |tc|
      if (port == tc.port)
        return true
      end
    end
    return false
  end

  def initialize
    @tomcats = []
    ps = `ps -ef | grep -e '-Dcatalina.home'`
    ps.split("\n").each() do |line|
      @tomcats << Tomcat.new($2, $1) if /^\s*\d+\s*(\d+).*-Dcatalina.home=(\S+)/ =~ line
    end
  end
end
