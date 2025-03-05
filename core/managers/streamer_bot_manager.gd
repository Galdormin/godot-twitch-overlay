extends Node

enum {CLOSED, CONNECTING, CONNECTED}

signal command_received(command: String, user: TwitchUser)
signal status_changed(status)

var socket: WebSocketPeer
var status = CLOSED:
	set(p_status):
		status_changed.emit(p_status)
		status = p_status

func _ready() -> void:
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
		status = CLOSED
		Loggie.msg("Connection closed to StreamerBot.").info()
		set_process(false)

func connect_to_websocket():
	var websocket_url = SettingsManager.get_settings("general").websocket_url
	socket = WebSocketPeer.new()
	
	status = CONNECTING
	get_tree().create_timer(3).timeout.connect(_has_connected)
	set_process(true)
	
	Loggie.msg("Connecting to StreamerBot on ", websocket_url).info()
	var err = socket.connect_to_url(websocket_url)
	if err:
		Loggie.msg("Unable to connect to StreamerBot. Code: ", err).error()
		set_process(false)
		return

func _has_connected():
	if status == CONNECTED:
		return
	
	status = CLOSED
	Loggie.msg("Couldn't connect to StreamerBot.").warn()
	set_process(false)

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
		status = CONNECTED
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
