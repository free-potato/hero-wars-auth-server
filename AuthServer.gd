extends Node

const SERVER_PORT = 1911
const MAX_GATEWAYS = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	start_server()

func start_server():
	var network = NetworkedMultiplayerENet.new()
	network.create_server(SERVER_PORT, MAX_GATEWAYS)
	get_tree().network_peer = network
	
	print("Auth Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	

func _peer_connected(gateway_id):
	print("Gateway connected: " + str(gateway_id))

func _peer_disconnected(gateway_id):
	print("Gateway disconnected: " + str(gateway_id))
	
remote func remote_authenticate_player(username, password, peer_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = {"status": false, "message": "incorrect-details", "username": null, "token": null}
	username = Player.sanitize_username(username)
	
	if Player.auth_player(username, password):
		var token = Token.generate()
		result["status"] = true
		result["message"] = "logged-in"
		result["username"] = username
		result["token"] = token
		GameServer.send_player_auth_details({"username": username, "token": token})
	
	rpc_id(gateway_id, "remote_authentication_result", result, peer_id)
	
remote func remote_create_account(username, password, peer_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = {"status": false, "message": "", "username": null, "token": null}
	username = Player.sanitize_username(username)
	
	if username.length() < 3:
		result["status"] = false
		result["message"] = "username-too-short"
	elif password.length() < 6:
		result["status"] = false
		result["message"] = "password-too-short"
	elif Player.player_exists(username):
		result["status"] = false
		result["message"] = "username-taken"
	else:
		var token = Token.generate()
		Player.create_player(username, password)
		result["status"] = true
		result["message"] = "success"
		result["username"] = username
		result["token"] = token
		GameServer.send_player_auth_details({"username": username, "token": token})

	rpc_id(gateway_id, "remote_create_account_result", result, peer_id)
