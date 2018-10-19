require_relative "../config/environment.rb"
# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]
require 'pry'
class Student
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil) # id not set yet
    @name = name
    @grade = grade
    @id = id
  end

  def save # instance method
    # check to see if the object it is being called on has already been persisted.
    if self.id
      self.update # If so, don't INSERT a new row into the database, simply update an existing one.
    else
    # inserts a new row into the DB using the attrs of the given object
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      # ALSO assigns the id attr of the object once the row has been inserted into the db
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end # end of if statement
  end # end of save method

  def update
    sql = "UPDATE students SET name = ?, grade = ?"
    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table # class method
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table # class method
    sql = "DROP TABLE IF EXISTS students"

   DB[:conn].execute(sql)
  end

  def self.create(name, grade) # class method
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row) # row is an array, READING THE DATABASE, converting db into ruby
    # binding.pry
    new_student = self.new(row[1], row[2], row[0])
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end






end # end of Student class
