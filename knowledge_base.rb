=begin
--------------------------------------------------------------------------------

Info about the content models (knowledge base) for this data store.

--------------------------------------------------------------------------------
=end
require 'tempfile'

class KnowledgeBase
  def self.create(props, instance)
    case props.kb_type
    when "sdb"
      SdbKnowledgeBase.new(props)
    when "tdb"
      TdbKnowledgeBase.new(props)
    when "custom"
      require instance.file("custom_knowledge_base")
      CustomKnowledgeBase.new(props)
    else
      raise SettingsError.new("Settings do not contain a valid value for kb_type: #{props.kb_type}")
    end
  end
end

# The template for KnowledgeBase classes
class KnowledgeBase
  def confirm()
    raise "KnowledgeBase.confirm() not implemented."
  end

  def erase()
    raise "KnowledgeBase.erase() not implemented."
  end

  def create()
    raise "KnowledgeBase.create() not implemented."
  end

  def size()
    raise "KnowledgeBase.size() not implemented."
  end

  def empty?()
    raise "KnowledgeBase.empty?() not implemented."
  end

  def running?()
    raise "KnowledgeBase.running?() not implemented."
  end

  def startup()
    raise "KnowledgeBase.startup() not implemented."
  end

  def shutdown()
    raise "KnowledgeBase.shutdown() not implemented."
  end

  def to_s()
    raise "KnowledgeBase.to_s() not implemented."
  end

end

class TdbKnowledgeBase < KnowledgeBase
  def initialize(props)
    @path = props.tdb_path || "#{props.vivo_home}/tdbContent"
  end

  def confirm()
    raise SettingsError.new("TDB directory doesn't exist at #{@path}") unless Dir.exist?(@path)
  end

  def erase()
    system("rm -rf #{@path}")
  end

  def create()
    system("mkdir #{@path}")
  end

  def size()
    begin
      return 0 unless /^(\d+)/ =~ `du -s #{@path}`
      $1.to_i()
    rescue
      0
    end
  end

  def empty?()
    return size() == 0
  end

  def running?()
    true
  end

  def startup()
    # No need to start up
  end

  def shutdown()
    # No need to shut down
  end

  def to_s()
    if empty?
      "tdb: empty"
    else
      "tdb: #{size()} bytes"
    end
  end
end

class SdbKnowledgeBase < KnowledgeBase
  def initialize(props)
    @db_name = props.db_name
    raise SettingsError.new("Settings do not contain a value for db_name") unless @db_name
  end

  def mysql(commands)
    puts "executing: #{commands}"
    file = Tempfile.new('kb')
    file.write(commands)
    file.close
    system("mysql -u root < #{file.path}")
    file.unlink
  end

  def confirm()
    databases = `echo "show databases;" | mysql -u root`
    raise SettingsError.new("Database #{@db_name} doesn't exist") unless databases.match("^#{@db_name}$")
  end

  def erase()
    mysql("drop database #{@db_name}; ")
  end

  def create()
    mysql(
    "create database #{@db_name} character set utf8 ; " +
    "grant all on #{@db_name}.* to vivoUser@localhost identified by 'vivoPass' ;"
    )
  end

  def size()
    begin
      command = "select TABLE_ROWS from information_schema.TABLES where TABLE_SCHEMA = '#{@db_name}' and TABLE_NAME = 'Quads';"
      response = `echo "#{command}" | mysql -u root`
      return 0 unless /(\d+)/ =~ response
      return $1.to_i()
    rescue
      0
    end
  end

  def empty?()
    return size() == 0
  end

  def running?()
    true
  end

  def startup()
    # No need to start up
  end

  def shutdown()
    # No need to shut down
  end

  def to_s()
    if empty?
      "database '#{@db_name}': empty"
    else
      "database '#{@db_name}': #{size()} triples"
    end
  end

end