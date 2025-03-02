extends Node

const SETTINGS_FILE_PATH: String = "user://settings.cfg"

var settings: AllSettings = AllSettings.new()

func _ready() -> void:
	load_settings()


func save_settings():
	var config = ConfigFile.new()

	var settings_properties = settings.get_setting_properties()
	for category_name in settings_properties:
		for section_name in settings_properties[category_name]:
			var cfg_section_name = category_name.to_upper() + "/" + section_name.to_upper()			
			for property in settings_properties[category_name][section_name]:
				var value = settings.get(category_name).get(property.name)
				config.set_value(cfg_section_name, property.name, value)
	
	config.save(SETTINGS_FILE_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE_PATH)
	if err != OK:
		Loggie.msg("opening config file failed. Code: " + str(err)).error()
		reset_settings()
		return
	
	var settings_properties = settings.get_setting_properties()
	for category_name in settings_properties:
		for section_name in settings_properties[category_name]:
			var cfg_section_name = category_name.to_upper() + "/" + section_name.to_upper()
			if not config.has_section(cfg_section_name):
				continue
			
			for property in settings_properties[category_name][section_name]:
				if config.has_section_key(cfg_section_name, property.name):
					var value = config.get_value(cfg_section_name, property.name)
					settings.get(category_name).set(property.name, value)

func reset_settings():
	settings = AllSettings.new()
