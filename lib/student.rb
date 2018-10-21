require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students(
    name TEXT,
    grade TEXT,
    id INTEGER PRIMARY KEY
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students;")
  end

  # saves an instance of the Student class to the database and then sets the given students `id` attribute. Updates a record if called on an object that is already persisted
  def save
    sql = <<-SQL
    INSERT INTO students(name, grade)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    if self.id == nil
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end
  end

  # creates a student object with name and grade attributes
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.all
    sql = <<-SQL
    SELECT * FROM STUDENTS
    SQL

    DB[:conn].execute(sql).map {|row| self.new_from_db(row)}
  end
  # creates an instance with corresponding attribute values
  def self.new_from_db(row)
    name = row[1]
    grade = row[2]
    id = row[0]
    s1 = Student.new(name, grade, id)
  end

  #returns an instance of student that matches the name from the DB
  def self.find_by_name(name)
    self.all.find(name) {|student| student.name == name}
    #alternatively we could have queried the DB here instead of calling all.
  end

  #  updates the record associated with a given instance
  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?", self.name, self.grade, self.id)
  end


end
