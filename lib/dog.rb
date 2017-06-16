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

  def self.create(dog_hash)
    new_dog = self.new(dog_hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT id, name, breed
      FROM dogs
      WHERE id = ?;
    SQL
    row = DB[:conn].execute(sql, id).first
    self.new_from_db(row)

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, breed
      FROM dogs
      WHERE name = ?;
    SQL
    row = DB[:conn].execute(sql, name).first
    self.new_from_db(row)

  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT id, name, breed
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    search = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).first

    if search == nil
      self.create(dog_hash)
    else
      self.new_from_db(search)
    end

  end

  def save
    sql = <<-SQL
      SELECT id, name, breed
      FROM dogs
      WHERE id = ?;
    SQL

    search = DB[:conn].execute(sql, self.id)

    if search.empty?
      #INSERT
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      sql = <<-SQL
      SELECT id
      FROM dogs
      ORDER BY id DESC LIMIT 1;
      SQL

      self.id = DB[:conn].execute(sql).first.first
      self

    else
      #UPDATE
      sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = #{self.id};
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = #{self.id};
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
  end



end
