require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'


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