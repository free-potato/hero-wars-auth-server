extends Node

const SERVER_PORT = 1912
const MAX_SERVERS = 10

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var game_server_ids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	start_server()
	
func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func start_server():
	network.create_server(SERVER_PORT, MAX_SERVERS)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	print("GameServerHub initialized")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	

func _peer_connected(game_server_id):
	print("Game server connected: " + str(game_server_id))
	game_server_ids.append(game_server_id)

func _peer_disconnected(game_server_id):
	print("Game server disconnected: " + str(game_server_id))
	game_server_ids.erase(game_server_id)
	
func send_player_auth_details(details):
	rpc_id(game_server_ids.back(), "remote_receive_player_auth_details", details)
