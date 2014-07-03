# Not independently executable

=begin
--------------------------------------------------------------------------------

Read the properties, wherever you may find them.

If path is specified, read from that instance. Otherwise, read from the current
instance.

Get the instance path from the settings file.

There are some default values, based on the instance path, etc.

A properties file in the instance directory will override the defaults.

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

require 'tempfile'

class InstanceControlProperties
  attr_reader :props

  # ------------------------------------------------------------------------------------
  private
  # ------------------------------------------------------------------------------------
  #
  def find_current_path()
    begin
      @props.merge!(PropertyFileReader.read($settings_file))
      self.instance_path
    rescue
      warning("Failed to read settings file: #{$settings_file}")
      $@
      nil
    end
  end

  def set_instance_defaults()
    self.vivo_source = File.expand_path('VIVO', @instance_dir)
    self.vitro_source = File.expand_path('Vitro', @instance_dir)
    self.catalina_home = File.expand_path('tomcat', @instance_dir)
  end

  def read_from_instance()
    if @instance_dir
      props_file = File.expand_path('instance-control.properties', @instance_dir)
      if File.exists?(props_file)
        begin
          @props.merge!(PropertyFileReader.read(props_file))
        rescue
          warning("Failed to read #{props_file}")
        end
      end
    end
  end

  # ------------------------------------------------------------------------------------
  public
  # ------------------------------------------------------------------------------------

  def initialize(path=nil)
    @props = {}

    @instance_dir = path || find_current_path()
    set_instance_defaults()
    read_from_instance()
  end

  def method_missing method_id, *args
    if args.empty?
      @props[method_id.to_s]
    elsif method_id.to_s.end_with?('=')
      @props[method_id.to_s.chop] = args[0]
    else
      super
    end
  end

end
