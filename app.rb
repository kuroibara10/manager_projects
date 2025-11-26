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
  begin
    @projects = DB.execute("SELECT * FROM projects")
    erb :"users/home"
  rescue => e
    halt 500, "Failed to load users: #{e.message}"
  end
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
post "/project" do
  name = params[:name]
  discription = params[:discription]
  email = params[:eamil]
  begin
    DB.execute(
      "INSERT INTO projects (name, discription, eamil) VALUES (?, ?, ?)",
      [name, discription, eamil]
    )

    @message = "Project created successfully!"
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
