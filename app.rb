require  'sinatra'
require  'slim'
require  'sinatra/reloader'
require 'csv'
require 'sqlite3'


enable :sessions

get('/') do 
  slim(:login)
end 

get('/login') do
  slim :login
end

get('/main') do
  slim :main
end

post('/login') do
 
  username = params[:username]
  password = params[:password]

  user = DB.execute('SELECT * FROM users WHERE username = ? AND password = ?', username, password).first

  variable = nil
  registered_user = variable || session[:registered_user]

  if registered_user == nil || registered_user == nil 
    session[:key] = nil
    session[:key2] = nil
    redirect('/fel')

  elsif registered_user[:username] == session[:key] && registered_user[:password] == session[:key2] 
    redirect('/main')
  else
    session[:key] = nil
    session[:key2] = nil
    redirect('/fel')
  end
end

get ('/fel') do
  slim(:fel)
end 

get ('/register') do
  slim(:register)
end 

post('/register') do
  username = params[:username]
  password = params[:password]

  db = SQLite3::Database.new("Data/pokemon.db")
  db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, password])

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
 
