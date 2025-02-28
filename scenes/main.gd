extends Control


@onready var setting_window = $MarginContainer/SettingWindow
@onready var connection_label = %ConnectionLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StreamerBotManager.status_changed.connect(_on_streamerbot_status_changed)
	_update_streamerbot_status(StreamerBotManager.status)


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

#endregion
