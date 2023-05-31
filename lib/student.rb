require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id
    #initializing  attributes
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
  
  def self.create_table
    # Creating a table named "students" if it doesn't exist
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql) 
  end

  def self.drop_table
    # Drop the "students" table if it exists
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql) 
  end
  
  def save
    if self.id
      self.update
    else
      # Insert the student's name and grade into the "students" table
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      # Set the student's id to the last inserted row id from the "students" table
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    # Create a new student instance, save it to the database, and return the student object
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    # Create a new student instance from a database row
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    # Find a student in the database based on their name and return a new student instance
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

  def update
    # Update the student's name and grade in the database based on their id
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end

