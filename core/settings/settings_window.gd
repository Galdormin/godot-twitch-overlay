extends Panel

@onready var settings_container = %SettingsContainer

func _ready() -> void:
	for category in SettingsManager.get_settings_categories():
		var tab_name = StringUtils.snake_case_to_title(category)
		add_settings(tab_name, SettingsManager.get_settings(category))


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
