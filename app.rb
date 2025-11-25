require 'sinatra'
require 'sinatra/reloader' if development?

set :bind, '0.0.0.0'
set :port, 8080
enable :sessions

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