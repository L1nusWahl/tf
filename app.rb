require_relative 'Model/Model.rb'
require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'

enable :sessions
include Model

helpers do
  def current_user_admin?
    session[:id] && session[:role] == 1
  end
end

# Display the landing page or login page if not authenticated
#
get('/') do 
  slim(:"users/login")
end 

# Displays the login form
#
get('/users/login') do
  slim(:"users/login")
end

# Logs out the current user by clearing the session
#
post('/logout') do
  session.clear
  redirect('/') 
end

# Authenticates the user based on username and password
#
# @param [String] username, The username of the user
# @param [String] password, The password of the user
#
# @see Model#login_user
post('/users/login') do
  login_user(params[:username], params[:password])
end

# Displays an error page
#
get('/fel') do
  slim(:fel)
end

# Displays the user registration form
#
get('/users/register') do
  slim(:"users/register")
end 

# Registers a new user
#
# @param [String] username, The username of the new user
# @param [String] password, The password of the new user
# @param [String] confirm_password, The confirmation of the password
#
# @see Model#register_new_user
post('/register') do
  register_new_user(params[:username], params[:password], params[:confirm_password])
end

# Displays the home page after successful login
#
get('/home') do 
  slim(:home)
end 

# Displays the list of pokémon if the user is an admin
#
# @see Model#display_pokemon_list
get('/pokemon') do
  display_pokemon_list
end

# Removes a pokémon from the database
#
# @param [Integer] id, The id of the pokémon to be removed
#
# @see Model#remove_pokemon
post('/remove_pokemon/:id') do
  remove_pokemon(params[:id])
end

# Adds a new pokémon to the database
#
# @param [String] pokemon_name, The name of the new pokémon
#
# @see Model#add_new_pokemon
post('/add/new_pokemon') do
  add_new_pokemon(params[:pokemon_name])
end

# Displays the list of user's todos
#
# @see Model#display_user_todos
get('/todos') do
  display_user_todos
end 

# Displays the form to create a new todo
#
get('/todos/new_todos') do
  slim(:"todos/new_todos")
end

# Creates a new todo
#
# @param [String] team_name, The name of the team for the todo
#
# @see Model#create_new_todo
post('/todos/new_todos') do 
  create_new_todo(params[:team_name], session[:id])
end 

# Updates an existing todo
#
# @param [Integer] id, The id of the todo to be updated
# @param [String] team_name, The updated name of the team
#
# @see Model#update_todo
post('/todos/:id/update') do 
  update_todo(params[:id], params[:team_name])
end 

# Deletes an existing todo
#
# @param [Integer] id, The id of the todo to be deleted
#
# @see Model#delete_todo
post('/todos/:id/delete') do 
  delete_todo(params[:id])
end 

# Displays the edit page for a team
#
# @param [Integer] id, The id of the team
#
# @see Model#display_team_edit_page
get('/teams/:id/edit') do
  display_team_edit_page(params[:id])
end

# Adds a pokémon to a team
#
# @param [Integer] id, The id of the team
# @param [Integer] pokemon_id, The id of the pokémon
#
# @see Model#add_pokemon_to_team
post('/teams/:id/add_pokemon') do
  add_pokemon_to_team(params[:id], params[:pokemon_id])
end

# Removes a pokémon from a team
#
# @param [Integer] id, The id of the team
# @param [Integer] pokemon_id, The id of the pokémon to be removed
#
# @see Model#remove_pokemon_from_team
post('/teams/:id/remove_pokemon/:pokemon_id') do
  remove_pokemon_from_team(params[:id], params[:pokemon_id])
end

# Adds a move to a pokémon in a team
#
# @param [Integer] team_id, The id of the team
# @param [Integer] pokemon_id, The id of the pokémon
# @param [Integer] move_id, The id of the move
#
# @see Model#add_move_to_pokemon
post('/teams/:team_id/add_move/:pokemon_id') do
  add_move_to_pokemon(params[:team_id], params[:pokemon_id], params[:move_id])
end

# Displays the page to choose moves for a team's pokémon
#
# @param [Integer] id, The id of the team
#
# @see Model#display_choose_moves_page
get('/teams/:id/choose_moves') do
  display_choose_moves_page(params[:id])
end

# Updates the name of a team
#
# @param [Integer] id, The id of the team
# @param [String] team_name, The updated name of the team
#
# @see Model#update_team_name
post('/teams/:id') do
  update_team_name(params[:id], params[:team_name])
end