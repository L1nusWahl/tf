require 'sqlite3'
require 'bcrypt'

module Model
  # Logs in a user
  #
  # @param [String] username The username of the user
  # @param [String] password The password of the user
  #
  # @return [Integer] The ID of the user if login is successful
  # @return [nil] if no user with the given username is found
  def login_user(username, password)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.results_as_hash = true 
    result = db.execute('SELECT * FROM users WHERE username = ?', username).first

    log = db.execute("SELECT * FROM Userlog WHERE Userip = ? AND Time > ?",request.ip, (Time.now.to_i - 300))   
    if log.count >= 5     
      flash[:notice] = "Too many login attempts"     
      redirect('/users/login')   
    else     
      db.execute("INSERT INTO Userlog (Userip,Time) VALUES (?,?)",request.ip, Time.now.to_i)

      if result.nil?
        redirect('/fel')
      end 

      id = result["id"]
      password_digest = result["password_digest"]
      role = result["role"]
      

      if BCrypt::Password.new(password_digest) == password
        session[:id] = id
        session[:role] = role 
        redirect('/home')
      else
        redirect('/fel')
      end
    end 
  end
  

  # Registers a new user
  #
  # @param [String] username The username of the new user
  # @param [String] password The password of the new user
  # @param [String] confirm_password The confirmation of the password
  #
  # @return [nil]
  #   if the username already exists or passwords do not match
  # @return [Integer] The ID of the newly registered user
  def register_new_user(username, password, confirm_password)
    db = SQLite3::Database.new("Data/Pokemon.db")

    result = db.execute("SELECT id FROM users WHERE username=?", username)

    if result.empty?
      if password == confirm_password
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users (username, password_digest) VALUES (?,?)", [username, password_digest])
        redirect('/users/login')  
      else 
        redirect('/fel')
      end 
    else 
      redirect('/fel')
    end
  end

  # Displays the list of pokémon
  #
  # @return [Array] containing the data of all pokémon
  def display_pokemon_list
    if current_user_admin?
      db = SQLite3::Database.new("Data/Pokemon.db")
      db.results_as_hash = true 
      @all_pokemon = db.execute("SELECT * FROM Pokemon")
      slim(:pokemon)
    else
      redirect('/fel')
    end
  end

  # Removes a pokémon from the database
  #
  # @param [Integer] pokemon_id The ID of the pokémon to be removed
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if removal is successful
  def remove_pokemon(pokemon_id)
    if current_user_admin?
      db = SQLite3::Database.new("Data/Pokemon.db")
      db.execute("DELETE FROM Pokemon WHERE id = ?", pokemon_id)
      redirect('/pokemon')
    else
      redirect('/fel')
    end
  end

  # Adds a new pokémon to the database
  #
  # @param [String] pokemon_name The name of the new pokémon
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if addition is successful
  def add_new_pokemon(pokemon_name)
    if current_user_admin?
      db = SQLite3::Database.new("Data/Pokemon.db")
      db.execute("INSERT INTO Pokemon (name) VALUES (?)", pokemon_name)
      redirect('/pokemon')
    else
      redirect('/fel')
    end
  end

  # Displays the user's todos
  #
  # @return [Array] containing the data of all user's todos
  def display_user_todos
    id = session[:id].to_i
    db = SQLite3::Database.new('Data/Pokemon.db')
    db.results_as_hash = true 
    result = db.execute("SELECT * FROM Teams WHERE user_id = ?",id)
    p "alla todos #{result}"
    slim(:"todos/index",locals:{todos:result})
  end 

  # Creates a new todo
  #
  # @param [String] team_name The name of the team for the todo
  # @param [Integer] user_id The ID of the user creating the todo
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if creation is successful
  def create_new_todo(team_name, user_id)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.execute("INSERT INTO Teams(team_name, user_id) VALUES (?,?)",team_name, user_id)
    redirect('/todos')
  end 

  # Updates an existing todo
  #
  # @param [Integer] id The ID of the todo to be updated
  # @param [String] team_name The updated name of the team
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if update is successful
  def update_todo(id, team_name)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.execute("UPDATE Teams SET team_name=? WHERE id = ?",team_name,id)
    redirect('/todos')
  end 

  # Deletes an existing todo
  #
  # @param [Integer] id The ID of the todo to be deleted
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if deletion is successful
  def delete_todo(id)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.execute("DELETE FROM Teams WHERE id = ?", id)
    redirect('/todos')
  end 

  # Displays the edit page for a team
  #
  # @param [Integer] id The ID of the team
  #
  # @return [Array] containing the data of the team and related pokémon
  def display_team_edit_page(id)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.results_as_hash = true
    
    @team = db.execute("SELECT * FROM Teams WHERE id = ?", id).first
    @pokemon_in_team = db.execute("SELECT * FROM TeamPokemons WHERE team_id = ?", id)
    @all_pokemon = db.execute("SELECT * FROM Pokemon")
    @all_moves = db.execute("SELECT * FROM Moves") 
    
    slim(:"todos/edit", locals: {team:@team, pokemon_in_team:@pokemon_in_team, all_pokemon:@all_pokemon})
  end

  # Adds a pokémon to a team
  #
  # @param [Integer] team_id The ID of the team
  # @param [Integer] pokemon_id The ID of the pokémon to be added
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if addition is successful
  def add_pokemon_to_team(team_id, pokemon_id)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.execute("INSERT INTO TeamPokemons(team_id, pokemon_id) VALUES (?, ?)", [team_id, pokemon_id])
    redirect("/teams/#{team_id}/edit")
  end

    
  # @param [Integer] team_id The ID of the team
  # @param [Integer] pokemon_id The ID of the pokémon to be removed
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if removal is successful
  def remove_pokemon_from_team(team_id, pokemon_id)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.execute("DELETE FROM TeamPokemons WHERE team_id = ? AND id = ?", [team_id, pokemon_id])
    redirect("/teams/#{team_id}/edit")
  end

  # Adds a move to a pokémon in a team
  #
  # @param [Integer] team_id The ID of the team
  # @param [Integer] pokemon_id The ID of the pokémon
  # @param [Integer] move_id The ID of the move to be added
  #
  # @return [nil]
  # @return [Integer] The number of rows affected if addition is successful
  def add_move_to_pokemon(team_id, pokemon_id, move_id)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.execute("INSERT INTO Moves_Pokemon(team_id, pokemon_id, move_id) VALUES (?, ?, ?)", [team_id, pokemon_id, move_id])
    redirect("/teams/#{team_id}/edit")
  end


  # Displays the page to choose moves for a team's pokémon
  #
  # @param [Integer] id The ID of the team
  #
  # @return [Array] containing the data of the team, related pokémon, and available moves

  def display_choose_moves_page(id)
    db = SQLite3::Database.new("Data/Pokemon.db")
    db.results_as_hash = true
    
    @team = db.execute("SELECT * FROM Teams WHERE id = ?", id).first
    @pokemon_in_team = db.execute("SELECT * FROM TeamPokemons WHERE team_id = ?", id)
    @all_moves = db.execute("SELECT * FROM Moves") 
    
    slim(:"todos/choose_moves", locals: { team: @team, pokemon_in_team: @pokemon_in_team, all_moves: @all_moves })
  end

end