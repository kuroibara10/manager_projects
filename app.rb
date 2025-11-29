require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'bcrypt'


set :bind, '0.0.0.0'
set :port, 8080
enable :sessions


DB = SQLite3::Database.new "db/myBasecamp1.db"
DB.results_as_hash = true

get '/dashboard/dashboard' do
  content_type :html
  begin
    @users = DB.execute("SELECT * FROM users")
    erb :"dashboard/dashboard"
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end
get '/' do
  content_type :html
  begin
    erb :index
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end
get '/sing_up' do
  content_type :html
  begin
    erb :sing_up
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end
get '/sing_up' do
  content_type :html
  begin
    erb :sing_up
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end
get '/login' do
  content_type :html
  begin
    erb :login
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end
get '/users/home' do
  content_type :html
  email = session[:email]
  @projects = DB.execute("SELECT * FROM projects WHERE email = ? ORDER BY id DESC",[email])
  @projects_created = DB.execute("SELECT * FROM projects WHERE email = ? ORDER BY id DESC",[email])
  @projects_shared = DB.execute("SELECT * FROM projects WHERE email = ? ORDER BY id DESC",[email])
  begin
    # @projects = DB.execute("SELECT * FROM projects ORDER BY id DESC")
    erb :"users/home"
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end

get '/project' do
  content_type :html
  id = params[:projectId]
  @project = DB.execute("SELECT * FROM projects WHERE id = ?",[id]).first
  @tasks = DB.execute("SELECT * FROM tasks WHERE project_id = ? ORDER BY id DESC",[id])
  @members = DB.execute("SELECT * FROM project_collaborations WHERE project_id = ?",[id])
  @discussions = DB.execute("SELECT * FROM discussions WHERE project_id = ? ORDER BY id DESC",[id])
  @chat_discussions = DB.execute("SELECT * FROM chat_discussion WHERE project_id = ? ORDER BY id DESC",[id])
  begin
    erb :"users/project"
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end
get '/projects/add' do
  content_type :html
  begin
    @projects = DB.execute("SELECT * FROM projects")
    erb :"users/add_project"
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
end

get '/projects/edit' do
  id = params[:projectId]
  @project = DB.execute("SELECT * FROM projects WHERE id = ?",[id]).first
  if @project.nil?
    halt 404, "Project #{id} not found"
  end

  erb :"users/edit_project"
end

# New user
post "/sing_up" do
  username = params[:username]
  email = params[:email]
  password = params[:password]
  password_conf = params[:password_conf]
  if(password != password_conf)
    begin
      session[:message] = "Please ensure both passwords are the same"
      session[:type] = "error"
      return erb :sing_up
    end
  end
  hashed_password = BCrypt::Password.create(password)
  begin
    DB.execute(
      "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
      [username, email, hashed_password]
    )
    session[:message] = "User created successfully!"
    session[:type] = "success"

    erb :sing_up
  rescue SQLite3::ConstraintException
    session[:message] = "Email already exists!"
    session[:type] = "error"

    erb :sing_up
  end
end

# Get user
post "/login" do
  email = params[:email]
  password = params[:password]
  user = DB.execute("SELECT * FROM users WHERE email = ?", [email]).first

  if user.nil?
    session[:message] = "Email not found!"
    session[:type] = "error"
    return erb :login
  end
  if BCrypt::Password.new(user["password"]) == password
    session[:user_id] = user["id"]
    session[:email] = user["email"]
    redirect "/users/home"
  else
    session[:message] = "Incorrect password!"
    session[:type] = "error"
    erb :login
  end
end
# Log out
get "/logout" do
  session.clear
  redirect "/login"
end

# New Project
post "/project/add" do
  name = params[:name]
  discription = params[:discription]
  email = params[:email]
  begin
    DB.execute(
      "INSERT INTO projects (name, discription, email) VALUES (?, ?, ?)",
      [name, discription, email]
    )
    project_id = DB.last_insert_row_id
    DB.execute(
      "INSERT INTO project_collaborations (project_id, email) VALUES (?, ?)",
      [project_id, email]
    )
    session[:message] = "Project #{name} created successfully!"
    session[:type] = "success"
    redirect "/users/home"
  rescue SQLite3::ConstraintException
    session[:message] = "Error create project: #{e.message}"
    session[:type] = "error"
    redirect "/users/home"
  end
end

# Update Project
put "/project/:id" do
  id = params[:id]
  name = params[:name]
  discription = params[:discription]
  begin
    DB.execute(
      "UPDATE projects SET name = ?, description = ? WHERE id = ?",
      [name, description, id]
    )
    @message = "Project update successfully!"
    @type = "success"


    erb :sing_up
  rescue SQLite3::ConstraintException
    @message = "Project Eroor!"
    @type = "error"

    erb :sing_up
  end
end

# Delete Project
delete "/users/home/:id" do
  id = params[:id]
  begin
    name_pro = DB.execute("SELECT name FROM projects WHERE id = ?", [id])
    name_p = name_pro[0]["name"]
    DB.execute("DELETE FROM projects WHERE id = ?", [id])
    session[:message] = "Project #{name_p} deleted successfully!"
    session[:type] = "success"
    redirect "/users/home"
  rescue => e
    status 500
    session[:message] = "Error deleting project: #{e.message}"
    session[:type] = "error"
    redirect "/users/home"
  end
end


# New Task
post "/task/add" do
  task = params[:task]
  project_id = params[:project_id]
  email = params[:email]
  @project = DB.execute("SELECT * FROM projects WHERE id = ?",[project_id]).first
  @tasks = DB.execute("SELECT * FROM tasks WHERE project_id = ? ORDER BY id DESC",[project_id])
  @members = DB.execute("SELECT * FROM project_collaborations WHERE project_id = ?",[project_id])
  @chat_discussions = DB.execute("SELECT * FROM chat_discussion WHERE project_id = ? ORDER BY id DESC",[project_id])
   @discussions = DB.execute("SELECT * FROM discussions WHERE project_id = ? ORDER BY id DESC",[project_id])

  begin
    DB.execute(
      "INSERT INTO tasks (task, email, project_id) VALUES (?, ?, ?)",
      [task, email, project_id]
    )
    session[:message] = "Task created successfully!"

    session[:type] = "success"
    erb :"users/project"
  rescue SQLite3::ConstraintException
    session[:message] = "Error create Task: #{e.message}"
    session[:type] = "error"
    erb :"users/project"
  end
end


# Update Project
put "/project/task/:id" do
  id = params[:id]
  task = params[:name]
  begin
    DB.execute(
      "UPDATE tasks SET task = ? WHERE id = ?",
      [task, id]
    )
    @message = "Task update successfully!"
    @type = "success"


    erb :sing_up
  rescue SQLite3::ConstraintException
    @message = "Task Eroor!"
    @type = "error"

    erb :sing_up
  end
end

# Delete Task
delete "/project/task/:id" do
  id = params[:id]
  begin
    name_task = DB.execute("SELECT task FROM tasks WHERE id = ?", [id])
    name_t = name_task[0]["name"]
    DB.execute("DELETE FROM tasks WHERE id = ?", [id])
    session[:message] = "Task #{name_p} deleted successfully!"
    session[:type] = "success"
    redirect "/users/home"
  rescue => e
    status 500
    session[:message] = "Error deleting task: #{e.message}"
    session[:type] = "error"
    redirect "/users/home"
  end
end

# New Discussion
post "/discussion/add" do
  titel_discussion = params[:titel_discussion]
  email = params[:email]
  project_id = params[:project_id]
  @project = DB.execute("SELECT * FROM projects WHERE id = ?",[project_id]).first
  @tasks = DB.execute("SELECT * FROM tasks WHERE project_id = ? ORDER BY id DESC",[project_id])
  @members = DB.execute("SELECT * FROM project_collaborations WHERE project_id = ?",[project_id])
  @chat_discussions = DB.execute("SELECT * FROM chat_discussion WHERE project_id = ? ORDER BY id DESC",[project_id])

  begin
    DB.execute(
      "INSERT INTO discussions (titel_discussion, email, project_id) VALUES (?, ?, ?)",
      [titel_discussion, email, project_id]
    )
    @discussions = DB.execute("SELECT * FROM discussions WHERE project_id = ? ORDER BY id DESC",[project_id])
    session[:projectId] = project_id
    session[:message] = "Discussion created successfully!"
    # redirect "/users/home"
    erb :"users/project"
  rescue SQLite3::ConstraintException
    session[:message] = "Error create Discussion: #{e.message}"
    session[:type] = "error"
    # redirect "/users/home"
    erb :"users/project"
  end
end

post "/discussion/caht/add" do
  message_d = params[:message_d]
  email = params[:email]
  project_id = params[:project_id]
  discussions_id = params[:discussions_id]
  @project = DB.execute("SELECT * FROM projects WHERE id = ?",[project_id]).first
  @tasks = DB.execute("SELECT * FROM tasks WHERE project_id = ? ORDER BY id DESC",[project_id])
  @members = DB.execute("SELECT * FROM project_collaborations WHERE project_id = ?",[project_id])

  begin
    DB.execute(
      "INSERT INTO chat_discussion (message_d, email, project_id, discussions_id) VALUES (?, ?, ?, ?)",
      [message_d, email, project_id, discussions_id]
    )
    @discussions = DB.execute("SELECT * FROM discussions WHERE project_id = ? ORDER BY id DESC",[project_id])
    @chat_discussions = DB.execute("SELECT * FROM chat_discussion WHERE project_id = ?",[project_id])
    session[:projectId] = project_id
    # session[:message] = "Discussion created successfully!"
    # redirect "/users/home"
    erb :"users/project"
  rescue SQLite3::ConstraintException
    @discussions = DB.execute("SELECT * FROM discussions WHERE project_id = ? ORDER BY id DESC",[project_id])
    @chat_discussions = DB.execute("SELECT * FROM chat_discussion WHERE project_id = ? ORDER BY id DESC",[project_id])

    # session[:message] = "Error create Discussion: #{e.message}"
    # session[:type] = "error"
    # redirect "/users/home"
    erb :"users/project"
  end
end

