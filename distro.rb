=begin
--------------------------------------------------------------------------------

Info about the source code distribution.

Is it git repositories or a release?
Is it older than release 1.5? 1.8 or newer?

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
=end

class Distro
  attr_reader :path
  attr_reader :props
  attr_reader :filename
  def initialize(path)
    @path = path
    @filename = File.basename(path)
  end

  def file(filename)
    File.expand_path(filename, @path)
  end

  def deploy(configurator, all_props)
    raise UserInputError.new("Stop tomcat first.") if $instance.tomcat.running?
    configurator.process_template_files(all_props)
    Dir.chdir(@props.vivo_path) do
      run_build_script(configurator.build_command())
    end
  end

  def run_build_script(command)
    raise SettingsError.new("Build failed.") unless system(command)
  end

  def self.create(path)
    begin
      Rel18GitDistro.new(path)
    rescue 
      begin
        EarlyGitDistro.new(path)
      rescue
        begin
          Rel15GitDistro.new(path)
        rescue
          begin
            ReleaseDistro.new(path)
          rescue
            begin
              OldReleaseDistro.new(path)
            rescue
              EmptyDistro.new(path)
            end
          end
        end
      end
    end
  end
end

class EarlyGitDistro < Distro
  def initialize(path)
    super
    @props = {"vitro_path" => file('Vitro'), "vivo_path" => file('VIVO')}.merge(PropertyFileReader.read(file('distro.properties')))
    confirm_props()
  end

  def confirm_props()
    raise "No Vitro source" unless File.exist?(@props.vitro_path)
    raise "Vitro source is not git workspace" unless File.exist?(File.expand_path(".git", @props.vitro_path))
    raise "No VIVO source" unless File.exist?(@props.vivo_path)
    raise "VIVO source is not git workspace" unless File.exist?(File.expand_path(".git", @props.vivo_path))
    raise "No example.build.properties" unless File.exist?(File.expand_path("example.build.properties", @props.vivo_path))
  end

  def status()
    vivo_status = Dir.chdir(@props.vivo_path) do
      format_git_status(`git status`)
    end

    vitro_status = Dir.chdir(@props.vitro_path) do
      format_git_status(`git status`)
    end

    "    Git Distribution\n    VIVO:\n#{vivo_status}    Vitro:\n#{vitro_status}"
  end

  def format_git_status(text)
    "        #{text.split("\n").select(){|s| !s.strip.empty?}.join("\n        ")}\n"
  end

  def update
    Dir.chdir(@props.vitro_path) { system "git pull" }
    Dir.chdir(@props.vivo_path) { system "git pull" }
  end

  def deploy(all_props, configurator=NewConfiguration.new())
    super(configurator, all_props)
  end
end

class Rel18GitDistro < EarlyGitDistro
  def confirm_props()
    raise "No application setup" unless File.exist?(File.expand_path("config/applicationSetup.n3", @props.vivo_path))
    super
  end

  def deploy(all_props)
    configurator = Rel18Configuration.new()
    super(all_props, configurator)
    configurator.inject_application_setup(all_props)
  end
end

class Rel15GitDistro < EarlyGitDistro
  def confirm_props()
    raise "No Vitro source" unless File.exist?(@props.vitro_path)
    raise "Vitro source is not git workspace" unless File.exist?(File.expand_path(".git", @props.vitro_path))
    raise "No VIVO source" unless File.exist?(@props.vivo_path)
    raise "VIVO source is not git workspace" unless File.exist?(File.expand_path(".git", @props.vivo_path))
    raise "No example.deploy.properties" unless File.exist?(File.expand_path("example.deploy.properties", @props.vivo_path))
  end

  def deploy(all_props, configurator=OldConfiguration.new())
    super(all_props, configurator)
  end
end

class BaseReleaseDistro < Distro
  def initialize(path)
    super
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
    "    Released distribution: #{@props.release_name}"
  end

  def deploy(all_props)
    super(NewConfiguration.new(), all_props)
  end
end

class OldReleaseDistro < BaseReleaseDistro
  def confirm_props
    raise "No example.deploy.properties" unless File.exist?(File.expand_path('example.deploy.properties', @props.vivo_path))
    super
  end

  def status()
    "    Released distribution (pre-1.5): #{@props.release_name}"
  end

  def deploy(all_props)
    super(OldConfiguration.new(), all_props)
  end
end

class EmptyDistro < Distro
  def initialize(path)
    super
    @props = {}
  end

  def status()
    "   Not a valid distribution: #{@path}"
  end

  def update()
    raise UserInputError.new(status())
  end

  def deploy(all_props)
    raise UserInputError.new(status())
  end
end

class NewConfiguration
  def process_template_files(all_props)
    Dir.mkdir($instance.file('_generated')) unless Dir.exist?($instance.file('_generated'))
    TemplateProcessor.new(all_props).process_complete($instance.distro_file('build.properties.template'), 
      $instance.file('_generated/build.properties'))
    TemplateProcessor.new(all_props).process_complete($instance.distro_file('runtime.properties.template'), 
      File.expand_path('runtime.properties', $instance.props.vivo_home))
  end

  def build_command()
    "ant all -Dbuild.properties.file=#{$instance.file('_generated/build.properties')}"
  end
end

class OldConfiguration
  def process_template_files(all_props)
    Dir.mkdir($instance.file('_generated')) unless Dir.exist?($instance.file('_generated'))
    TemplateProcessor.new(all_props).process_complete($instance.distro.file('deploy.properties.template'), 
      $instance.file('_generated/deploy.properties'))
  end

  def build_command()
    "ant all -Ddeploy.properties.file=#{$instance.file('_generated/deploy.properties')}"
  end
end

class Rel18Configuration < NewConfiguration
  def inject_application_setup(all_props)
    config_dir = File.expand_path('config', all_props.vivo_home)
    application_setup = $instance.file('applicationSetup.n3')
    FileUtils.cp(application_setup, config_dir) if File.exist?(application_setup)
  end
end
