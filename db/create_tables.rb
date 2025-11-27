require 'sqlite3'
DB = SQLite3::Database.new "myBasecamp1.db"
# DB.execute("DROP TABLE IF EXISTS projects")
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT,
    email TEXT UNIQUE,
    password TEXT
  );
SQL
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT,
    discription TEXT,
    members_users INTEGER DEFAULT 1,
    nb_discussion INTEGER DEFAULT 0
  );
SQL
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS discussions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    discussion TEXT,
    email TEXT,
    project_id INTEGER,
    FOREIGN KEY(project_id) REFERENCES projects(id)
  );
SQL
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task TEXT,
    email TEXT,
    project_id INTEGER,
    FOREIGN KEY(project_id) REFERENCES projects(id)
  );
SQL
# DB.execute("DROP TABLE IF EXISTS project_collaborations")
DB.execute <<-SQL
CREATE TABLE IF NOT EXISTS project_collaborations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER,
    email TEXT,
    FOREIGN KEY(project_id) REFERENCES projects(id)
);
SQL