require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(dog_hash)

    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = nil
  end

  def self.create_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.new_from_db(row)
    new_dog = Dog.new({name:row[1], breed:row[2]})
    new_dog.id = row[0]
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, breed
      FROM dogs
      WHERE name = ?
      );
    SQL
    row = DB[:conn].execute(sql, name)
    self.new_from_db(row)
    #WORKING ON THIS NOW
  end

end
