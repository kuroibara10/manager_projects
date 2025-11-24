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