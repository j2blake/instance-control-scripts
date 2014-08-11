=begin
--------------------------------------------------------------------------------

Info about the content models (knowledge base) for this data store.

--------------------------------------------------------------------------------
=end
require 'tempfile'

class KnowledgeBase
  def self.create(db_name)
    if db_name == 'tdb'
      TdbKnowledgeBase.new()
    else
      SdbKnowledgeBase.new(db_name)
    end
  end
end

class TdbKnowledgeBase < KnowledgeBase
  def confirm()
  end

  def erase()
    system("rm -rf #{$instance.vivo_home.path}/tdbContentModels")
  end

  def create()
    system("mkdir #{$instance.vivo_home.path}/tdbContentModels")
  end

  def size()
    begin
      return 0 unless /^(\d+)/ =~ `du -s #{$instance.vivo_home.path}/tdbContentModels`
      $1.to_i()
    rescue
      0
    end
  end

  def empty?()
    return size() == 0
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
  attr_reader :db_name
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

  def to_s()
    if empty?
      "database '#{@db_name}': empty"
    else
      "database '#{@db_name}': #{size()} triples"
    end
  end

  def initialize(db_name)
    @db_name = db_name
  end
end