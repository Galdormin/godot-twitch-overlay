extends Control


@onready var setting_window = $MarginContainer/SettingWindow


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_setting_button_pressed() -> void:
	setting_window.show()


func _on_reload_button_pressed() -> void:
	StreamerBotManager.connect_to_websocket()
