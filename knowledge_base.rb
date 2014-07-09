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

  def initialize(db_name)
    @db_name = db_name
  end
end