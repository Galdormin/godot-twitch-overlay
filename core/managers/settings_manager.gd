extends Node

const SETTINGS_FILE_PATH: String = "user://settings.cfg"

var config = ConfigFile.new()

func _ready() -> void:
	var err = config.load(SETTINGS_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		set_default_settings()
		save()
	elif err != OK:
		Loggie.msg("opening config file failed. Code: " + str(err)).error()
		return

func save():
	config.save(SETTINGS_FILE_PATH)

func set_default_settings():
	config.set_value("GENERAL", "WEBSOCKET_ADDRESS", "ws://127.0.0.1:8080/")
	config.set_value("GENERAL", "POKEMON_COMMAND", "!pkmn")
	config.set_value("GENERAL", "POKEMON_VOLUME", 0.5)

func get_setting(key: String) -> Variant:
	return config.get_value("GENERAL", key)

func set_setting(key: String, value: Variant):
	config.set_value("GENERAL", key, value)
