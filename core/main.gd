extends Control


@onready var overlay_container = %OverlayContainer
@onready var setting_window = %SettingWindow
@onready var connection_label = %ConnectionLabel


func _ready() -> void:
	StreamerBotManager.status_changed.connect(_on_streamerbot_status_changed)
	_update_streamerbot_status(StreamerBotManager.status)
	_load_overlays()


func _load_overlays() -> void:
	var overlay_folder = DirAccess.open("res://overlay")
	if not overlay_folder:
		Loggie.msg("An error occurred when trying to access the path.").error()
		return
	
	overlay_folder.list_dir_begin()
	while true:
		var file = overlay_folder.get_next()
		Loggie.msg("Loading overlay: " + file).info()
		if file == "":
			break
		
		_load_overlay("res://overlay/" + file)
	
	overlay_folder.list_dir_end()
		
func _load_overlay(path: String) -> void:
	var overlay_data = load(path + "/overlay.tres")
		
	# Load Overlay
	var overlay_scene = overlay_data.scene.instantiate()
	overlay_container.add_child(overlay_scene)
	overlay_scene.show()


func _update_streamerbot_status(status) -> void:
	match status:
		StreamerBotManager.CLOSED:
			connection_label.text = "Not connected to StreamerBot"
		StreamerBotManager.CONNECTING:
			connection_label.text = "Connecting to StreamerBot..."
		StreamerBotManager.CONNECTED:
			connection_label.text = "Connected to StreamerBot"

#region Signals

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_setting_button_pressed() -> void:
	setting_window.show()


func _on_reload_button_pressed() -> void:
	StreamerBotManager.connect_to_websocket()


func _on_streamerbot_status_changed(status) -> void:
	_update_streamerbot_status(status)


func _on_overlay_button_pressed() -> void:
	OverlayLoader.open_overlay_folder()

#endregion
