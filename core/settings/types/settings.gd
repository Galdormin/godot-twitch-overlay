class_name Settings
extends Resource


func get_settings_properties() -> Dictionary:
	var properties = {}
	var current_section = ""
	
	for property in get_property_list():
		if not property.has("usage"):
			continue
		
		# Handle Categories
		if property.usage & PROPERTY_USAGE_CATEGORY:
			if property.name in ["RefCounted", "Resource"] or property.name.ends_with(".gd"):
				continue
			
			current_section = property.name
			properties[current_section] = []
		
		# Handle Attributes
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property.usage & PROPERTY_USAGE_EDITOR:
			if not current_section:
				Loggie.msg("Setting attribute '%s' has been skipped because it has no section." % property.name).warn()
				continue
			
			property["value"] = get(property.name)
			property["default"] = get_default_value(property.name)
			properties[current_section].append(property)
	
	return properties


func get_default_value(property_name: String) -> Variant:
	var default_instance = get_script().new()
	return default_instance.get(property_name)
