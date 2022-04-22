extends Node

const HASH_TYPE = "custom_sha256"

# returns null if a player with given username does not exists
func get_player(username):
	var players = self.players()
	var player  = players[username] if self.player_exists(username) else null
	return player
	
func create_player(username, password):
	username = self.sanitize_username(username)
	
	if self.player_exists(username):
		return null
		
	var players = self.players()
	var salt = self.generate_salt()
	var password_hash = self.custom_sha256(password, salt)
	
	players[username] = {
		"password_hash": password_hash, 
		"salt": salt,
		"hash_type": HASH_TYPE
	}
	
	var file = File.new()
	file.open("res://data/players.dat", File.WRITE)
	file.store_var(players)
	file.close()
	
func auth_player(username, password):
	var result = false
	if self.player_exists(username):
		var player = self.get_player(username)
		result = player["password_hash"] == self.custom_sha256(password, player["salt"])
	return result
	
func generate_salt():
	randomize()
	return str(randi()).sha256_text()

func custom_sha256(password, salt):
	var password_hash = password
	var complexity = pow(2, 16)
	
	for cycle in range(complexity):
		password_hash = (password_hash.left(32) + password_hash + salt).sha256_text()
	
	return password_hash

func player_exists(username):
	var players = self.players()
	if username in players:
		return true
	return false
	
# TODO: allow only text and numbers
func sanitize_username(username):
	return username.to_lower().strip_edges().replace(" ", "").replacen(" ", "").left(64).json_escape()
	
func players():
	var file = File.new()
	file.open("res://data/players.dat", File.READ)
	var players = file.get_var()
	file.close()
	if players == null:
		players = {}
	return players
