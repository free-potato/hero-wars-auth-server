extends Node


func generate():
	randomize()
	return (str(OS.get_unix_time()) + str(randi())).sha256_text()
