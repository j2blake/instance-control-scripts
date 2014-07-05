=begin
--------------------------------------------------------------------------------

Info about the source code distribution.
Is it git repositories or a release?
Is it older than release 1.5?

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

class Distro
  attr_reader :path
  attr_reader :props
  def file(filename)
    File.expand_path(filename, @path)
  end
  
  def deploy(configurator)
    raise UserInputError.new("Stop tomcat first.") if $instance.tomcat.running?
    configurator.process_template_files()
    run_build_script(configurator.build_command())
  end

  def run_build_script(command)
    raise SettingsError.new("Build failed.") unless system(command)
  end
  
  def self.create(path)
    begin
      GitDistro.new(path)
    rescue
      bogus("Not git distro: #{$!}")
      begin
        ReleaseDistro.new(path)
      rescue
        bogus("Not release distro: #{$!}")
        begin
          OldReleaseDistro.new(path)
        rescue
          bogus("Not old release distro: #{$!}")
          EmptyDistro.new(path)
        end
      end
    end
  end
end

class GitDistro < Distro
  def initialize(path)
    @path = path
    @props = {"vitro_path" => file('Vitro'), "vivo_path" => file('VIVO')}.merge(PropertyFileReader.read(file('distro.properties')))
    confirm_props()
  end

  def confirm_props()
    raise "No Vitro source" unless File.exist?(@props.vitro_path)
    raise "Vitro source is not git workspace" unless File.exist?(File.expand_path(".git", @props.vitro_path))
    raise "No VIVO source" unless File.exist?(@props.vivo_path)
    raise "VIVO source is not git workspace" unless File.exist?(File.expand_path(".git", @props.vivo_path))
  end

  def status()
    puts "git status:"
    puts "    VIVO:"
    Dir.chdir(@props.vivo_path) { format_git_status(`git status`) }
    puts "    Vitro:"
    Dir.chdir(@props.vitro_path) { format_git_status(`git status`) }
  end

  def format_git_status(text)
    puts "        #{text.split("\n").join("\n        ")}"
  end

  def update  
    Dir.chdir(@props.vitro_path) { system "git pull" }
    Dir.chdir(@props.vivo_path) { system "git pull" }
  end
  
  def deploy()
    super(NewConfiguration.new())
  end
end

class BaseReleaseDistro < Distro
  def initialize(path)
    @path = path
    @props = {"vivo_path" => locate_release_dir()}.merge(PropertyFileReader.read(file('distro.properties')))
    @props.vitro_path = File.expand_path('vitro-core', @props.vivo_path)
    @props.release_name = File.basename(@props.vivo_path)
    confirm_props()
  end

  def locate_release_dir()
    Dir.foreach(@path) do |filename|
      return file(filename) if is_release_directory(filename)
    end
    return 'not found'
  end

  def is_release_directory(filename)
    return filename.start_with?('vivo-rel-')
  end

  def confirm_props()
    raise "Unknown release" unless is_release_directory(@props.release_name)
    raise "No Vitro source" unless File.exist?(@props.vitro_path)
    raise "No VIVO source" unless File.exist?(@props.vivo_path)
  end
  
  def update()
    raise UserInputError.new("Not a git repository: release #{@props.release_name}")
  end
end

class ReleaseDistro < BaseReleaseDistro
  def confirm_props
    raise "No example.build.properties" unless File.exist?(File.expand_path('example.build.properties', @props.vivo_path))
    super
  end

  def status()
    "Source status: Released distribution: #{@props.release_name}"
  end
  
  def deploy()
    super(NewConfiguration.new())
  end
end

class OldReleaseDistro < BaseReleaseDistro
  def confirm_props
    raise "No example.deploy.properties" unless File.exist?(File.expand_path('example.deploy.properties', @props.vivo_path))
    super
  end

  def status()
    "Source status: Released distribution (pre-1.5): #{@props.release_name}"
  end

  def deploy()
    super(NewConfiguration.new())
  end
end

class EmptyDistro < Distro
  def initialize(path)
    @path = path
  end

  def status()
    "Not a valid distribution: #{@path}"
  end

  def update()
    raise UserInputError.new(status())
  end
  
  def deploy()
    raise UserInputError.new(status())
  end
end

class NewConfiguration
  def process_template_files()
    distro = $instance.distro
    TemplateProcessor.process_complete(distro.props, distro.file('build.properties.template'), $instance.file('build.properties'))
    TemplateProcessor.process_complete(distro.props, distro.file('runtime.properties.template'), $instance.home.file('runtime.properties'))
  end
  
  def build_command()
    "ant all -Dbuild.properties.file=#{$instance.file('build.properties')}"
  end
end

class OldConfiguration
  def process_template_files()
    distro = $instance.distro
    TemplateProcessor.process_complete(distro.props, distro.file('deploy.properties.template'), $instance.file('deploy.properties'))
  end
  
  def build_command()
    "ant all -Dbuild.properties.file=#{$instance.file('deploy.properties')}"
  end
end
