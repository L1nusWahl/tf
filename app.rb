require  'sinatra'
require  'slim'
require  'sinatra/reloader'
require 'csv'
require 'sqlite3'
require 'bcrypt'


enable :sessions

get('/') do 
  slim(:login)
end 

get('/login') do
  slim (:login)
end


post('/login') do
 
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.results_as_hash = true 
  result = db.execute('SELECT * FROM users WHERE username = ?', username).first
  user_id = result["id"]
  password_digest = result["password_digest"]

  if result.empty?
    redirect('/fel')
  end 

  if BCrypt::Password.new(password_digest) == password
    session[:user_id] = user_id 
    redirect('/teams')
  else
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
  password_confirmation = params[:confirm_password]
  db = SQLite3::Database.new("Data/Pokemon.db")

  result = db.execute("SELECT id FROM users WHERE username=?", username)

  if result.empty?
    if password == password_confirmation
      password_digest = BCrypt::Password.create(password)
      db.execute("INSERT INTO users (username, password_digest) VALUES (?,?)", [username, password_digest])
      redirect('/login')  
    else 
      redirect('/fel')
    end 
  else 

    redirect('/fel')
  end
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

get('/teams') do
  id = session[:id].to_i
  db = SQLite3::Database.new('Data/Pokemon.db')
  db.results_as_hash = true 
  result = db.execute("SELECT * FROM Teams WHERE user_id = ?", id)
  slim(:"teams/new_team", locals:{teams:result})
end 

get('/teams/new_team') do
  slim(:"teams/new_team")
end

post('/teams/new_team') do 
  team_name = params[:team_name]
  user_id = session[:id]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.execute("INSERT INTO Teams(team_name, user_id) VALUES (?, ?)", team_name, user_id)
  redirect('/teams')
end 

get('/teams/:id/edit') do
  id = params[:id]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Teams WHERE id = ?", id).first
  slim(:"teams/edit_team", locals: { result: result })
end

post('/teams/:id/delete') do 
  id = params[:id]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.execute("DELETE FROM Teams WHERE id = ?", id)
  redirect('/teams')
end