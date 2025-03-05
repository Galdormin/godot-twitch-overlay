extends Panel

@onready var settings_container = %SettingsContainer 


func add_settings(tab_name: String, settings: Settings):
	var autosettings = AutoSettings.new()
	autosettings.settings = settings
	autosettings.name = tab_name
	settings_container.add_child(autosettings)


func _save_settings():
	for auto_settings in settings_container.get_children():
		auto_settings.save_settings()
	
	SettingsManager.save_settings()


func _on_quit_button_pressed() -> void:
	_save_settings()
	hide()
