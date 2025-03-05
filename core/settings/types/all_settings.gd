class_name  AllSettings
extends Resource

@export var general: GeneralSettings = GeneralSettings.new()


func get_setting_properties() -> Dictionary:
	var properties = {}	
	for property in get_property_list():
		if not property.has("usage"):
			continue
		
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property.usage & PROPERTY_USAGE_EDITOR:
			var setting = get(property.name)
			properties[property.name] = setting.get_setting_properties()
	
	return properties
