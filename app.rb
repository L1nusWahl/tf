require  'sinatra'
require  'slim'
require  'sinatra/reloader'
require 'csv'


enable :sessions

get('/') do 
  slim(:login)
end 

get('/login') do
  slim :login
end

post('/login') do
 
  session[:key] = params[:user]
  session[:key2] = params[:pwd]
  registered_user = session[:registered_user]

  variable = nil
  registered_user = variable || session[:registered_user]

  if registered_user == nil || registered_user == nil 
    session[:key] = nil
    session[:key2] = nil
    redirect('/fel')

  elsif registered_user[:username] == session[:key] && registered_user[:password] == session[:key2] 
    redirect('/batman2')
  else
    session[:key] = nil
    session[:key2] = nil
    redirect('/fel')
  end
end

get ('/fel') do
  slim(:fel)
end 

post('/register') do
 
  session[:register_key] = params[:user]
  session[:register_key2] = params[:pwd]

  
  session[:registered_user] = {username: session[:register_key], password: session[:register_key2]}

  redirect('/login')  
end

post('/logga_ut') do 
  session[:key] = nil 
  session[:key2] = nil
  redirect('/')
end 

get('/data') do
  @data = CSV.open("data/MOCK_DATA.csv", headers: :first_row).map(&:to_h)
  slim(:info)
end
 
