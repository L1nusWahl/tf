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
  p "Reslut är #{result}"

  if result == nil
    redirect('/fel')
  end 
  id = result["id"]
  password_digest = result["password_digest"]

  if BCrypt::Password.new(password_digest) == password
    session[:id] = id 
    redirect('/todos')
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

get('/todos') do
  id = session[:id].to_i
  db = SQLite3::Database.new('Data/Pokemon.db')
  db.results_as_hash = true 
  result = db.execute("SELECT * FROM Teams WHERE user_id = ?",id)
  p "alla todos #{result}"
  slim(:"todos/index",locals:{todos:result})
end 

get('/todos/new_todos') do
  slim(:"todos/new_todos")
end


post('/todos/new_todos') do 
  team_name = params[:team_name]
  user_id = session[:id]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.execute("INSERT INTO Teams(team_name, user_id) VALUES (?,?)",team_name, user_id)
  redirect('/todos')
end 

post('/todos/:id/update') do 
  id = params[:id]
  team_name = params[:team_name]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.execute("UPDATE Teams SET team_name=? WHERE id = ?",team_name,id)
  redirect('/todos')
end 

post('/todos/:id/delete') do 
  id = params[:id]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.execute("DELETE FROM Teams WHERE id = ?", id)
  redirect('/todos')
end 

get('/teams/:id/edit') do
  id = params[:id]
  db = SQLite3::Database.new("Data/Pokemon.db")
  db.results_as_hash = true
  
  @team = db.execute("SELECT * FROM Teams WHERE id = ?", id).first
  
  @pokemon_in_team = db.execute("SELECT * FROM TeamPokemons WHERE team_id = ?", id)
  
  @all_pokemon = db.execute("SELECT * FROM Pokemon")
  
  slim(:"todos/edit", locals: {team:@team, pokemon_in_team:@pokemon_in_team, all_pokemon:@all_pokemon})
end

post('/teams/:id/add_pokemon') do
  team_id = params[:id]
  pokemon_id = params[:pokemon_id]

  db = SQLite3::Database.new("Data/Pokemon.db")
  
  db.execute("INSERT INTO TeamPokemons(team_id, pokemon_id) VALUES (?, ?)", [team_id, pokemon_id])

  redirect("/teams/#{team_id}/edit")
end


post('/teams/:id/remove_pokemon/:pokemon_id') do
  team_id = params[:id]
  pokemon_id = params[:pokemon_id]

  db = SQLite3::Database.new("Data/Pokemon.db")

  db.execute("DELETE FROM TeamPokemons WHERE team_id = ? AND pokemon_id = ?", team_id, pokemon_id)

  redirect("/teams/#{team_id}/edit")
end

put('/teams/:id') do
  id = params[:id]
  team_name = params[:team_name]

  db = SQLite3::Database.new("Data/Pokemon.db")
  
  db.execute("UPDATE Teams SET team_name = ? WHERE id = ?", [team_name, id])

  redirect('/todos')
end