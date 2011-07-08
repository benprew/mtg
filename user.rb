require 'bundler/setup'
require 'sinatra/base'
require 'bcrypt'

class User < Sinatra::Base

  include BCrypt

  if test?
    set :sessions, false
  else
    set :sessions, true
  end

  get '/logout' do
    session[:user] = nil
    redirect '/login?messages=You have been logged out'
  end

  get '/login' do
    haml "user/login".to_sym
  end

  get '/forgot_password' do
  end

  post '/login' do
    user = DB[:users].first(:username => params[:username])
    if user && Password.new(user[:password]) == params[:password]
      session[:user] = user
      session[:last_page_request] = Time.now()
      page = params[:request_path].match(/\w/) ? params[:request_path] : '/'
      redirect page
    else
      redirect '/login?errors=Incorrect username or password'
    end
  end


end
