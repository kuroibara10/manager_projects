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
      @message = "Please ensure both passwords are the same"
      @type = "error"
      return erb :sing_up
    end
  end
  hashed_password = BCrypt::Password.create(password)
  begin
    DB.execute(
      "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
      [username, email, hashed_password]
    )
    @message = "User created successfully!"
    @type = "success"

    erb :sing_up
  rescue SQLite3::ConstraintException
    @message = "Email already exists!"
    @type = "error"

    erb :sing_up
  end
end

# Get user
post "/login" do
  email = params[:email]
  password = params[:password]
  user = DB.execute("SELECT * FROM users WHERE email = ?", [email]).first
  if user.nil?
    @message = "Email not found!"
    return erb :login
  end
  if BCrypt::Password.new(user["password"]) == password
    session[:user_id] = user["id"]
    redirect "/users/home"
  else
    @message = "Incorrect password!"
    erb :login
  end
end
# Log out
get "/logout" do
  session.clear
  redirect "/login"
end