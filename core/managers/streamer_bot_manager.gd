extends Node

signal command_received(command: String, user: TwitchUser)

var socket: WebSocketPeer

func _ready() -> void:
	await SettingsManager.ready
	connect_to_websocket()

func _process(_delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			_handle_packet(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		Loggie.msg("WebSocket closed with code: ", code)
		set_process(false) # Stop processing

func connect_to_websocket():
	var websocket_url = SettingsManager.get_setting("WEBSOCKET_ADDRESS")
	socket = WebSocketPeer.new()
	
	Loggie.msg("Connection to StreamerBot on ", websocket_url).info()
	var err = socket.connect_to_url(websocket_url)
	if err:
		Loggie.msg("Unable to connect to StreamerBot. Code: ", err).error()
		set_process(false)
		return

func _subscribe():
	var subscribe = {
	  "request": "Subscribe",
	  "id": "godot-overlay",
	  "events": {
		"Command": [
		  "Triggered"
		]
	  },
	}
	
	socket.send_text(JSON.stringify(subscribe))

func _handle_packet(packet: PackedByteArray):
	var raw_data = packet.get_string_from_utf8()
	Loggie.msg("Got data from server: ", raw_data).debug()
	
	var data = JSON.parse_string(raw_data) as Dictionary
	if "request" in data:
		Loggie.msg("Connection successful to StreamerBot.").info()
		_subscribe()
		return
	
	if "events" in data:
		return
	
	if "event" in data:
		if data["event"]["source"] == "Command" and data["event"]["type"] == "Triggered":
			_handle_command(data["data"])

func _handle_command(data: Dictionary):
	var cmd_name = data["command"]
	var user_data = data["user"]
	var user = TwitchUser.new(user_data["display"], int(user_data["id"]))
	
	command_received.emit(cmd_name, user)
