=begin
--------------------------------------------------------------------------------

A utility class that finds out what tomcats are running.

--------------------------------------------------------------------------------
=end

module ICS
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
        @tomcats << Tomcat.new($2, $1) if /^\s*\d+\s*(\d+).*-Dcatalina.base=(\S+)/ =~ line
      end
    end
  end
end
