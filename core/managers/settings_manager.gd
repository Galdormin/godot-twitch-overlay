extends Node

const SETTINGS_FILE_PATH: String = "user://settings.cfg"


var _settings: Dictionary = {}


func _ready() -> void:
	set_settings("general", GeneralSettings.new())

	# Register overlay settings
	for overlay in OverlayLoader.get_overlay_list():
		set_settings(overlay.name, overlay.settings)
	
	load_settings()


# Returns the settings object for the given category.
func get_settings(category_name: String) -> Settings:
	return _settings[category_name]


# Stores a settings object for the given category.
func set_settings(category_name: String, settings: Settings) -> void:
	_settings[category_name] = settings


# Returns the list of all settings categories.
func get_settings_categories() -> Array:
	return _settings.keys()

# Saves settings to the config file path.
func save_settings():
	var config = ConfigFile.new()

	var settings_properties = get_settings_properties()
	for category_name in settings_properties:
		for section_name in settings_properties[category_name]:
			var cfg_section_name = category_name.to_upper() + "/" + section_name.to_upper()
			for property in settings_properties[category_name][section_name]:
				var value = _settings[category_name].get(property.name)
				config.set_value(cfg_section_name, property.name, value)
	
	config.save(SETTINGS_FILE_PATH)


# Loads settings from the config file or resets on error.
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE_PATH)
	if err != OK:
		Loggie.msg("opening config file failed. Code: " + str(err)).error()
		reset_settings()
		return
	
	var settings_properties = get_settings_properties()
	for category_name in settings_properties:
		for section_name in settings_properties[category_name]:
			var cfg_section_name = category_name.to_upper() + "/" + section_name.to_upper()
			if not config.has_section(cfg_section_name):
				continue
			
			for property in settings_properties[category_name][section_name]:
				if config.has_section_key(cfg_section_name, property.name):
					var value = config.get_value(cfg_section_name, property.name)
					_settings[category_name].set(property.name, value)


# Resets all settings to defaults.
func reset_settings():
	var settings_properties = get_settings_properties()
	for category_name in settings_properties:
		for section_name in settings_properties[category_name]:
			for property in settings_properties[category_name][section_name]:
				get(category_name).set(property.name, property.default_value)


# Returns a dictionary of all setting properties.
func get_settings_properties():
	var properties = {}
	for property in _settings:
		properties[property] = _settings[property].get_settings_properties()
	
	return properties