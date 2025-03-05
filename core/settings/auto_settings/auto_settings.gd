class_name AutoSettings
extends VBoxContainer

@export var settings: Settings


func _ready():
	if settings == null:
		Loggie.msg("No settings defined in AutoSettings.").error()
		return
	
	load_settings()
	_populate_settings()


func save_settings():
	for category in SettingsManager.settings.get_setting_properties():
		var cat_setting = SettingsManager.settings.get(category)
		if cat_setting.get_script() == settings.get_script():
			SettingsManager.settings.set(category, settings)


func load_settings():
	for category in SettingsManager.settings.get_setting_properties():
		var cat_setting = SettingsManager.settings.get(category)
		if cat_setting.get_script() == settings.get_script():
			settings = cat_setting


func _populate_settings():
	var properties = settings.get_setting_properties()
	for section in properties:
		_add_section(section)
		for property in properties[section]:
			_add_input(property)


func _add_section(section_name: String):
	var section_label = Label.new()
	section_label.text = convert_snake_case_to_title(section_name)
	add_child(section_label)
	add_child(HSeparator.new())


func _add_input(property: Dictionary):	
	var input_container = HBoxContainer.new()
	
	var input_label = Label.new()
	input_label.text = convert_snake_case_to_title(property.name)
	input_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_container.add_child(input_label)
	
	var input: Control
	match property.type:
		TYPE_BOOL:
			input = CheckButton.new()
			input.button_pressed = property.value
			input.toggled.connect(func(toggled_on): get("settings").set(property.name, toggled_on))
		TYPE_INT:
			input = SpinBox.new()
			input.value = property.value
			input.value_changed.connect(func(value): get("settings").set(property.name, value))
		TYPE_FLOAT:
			input = HSlider.new()
			input.max_value = 1
			input.step = 0.01
			input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			input.value = property.value
			input.value_changed.connect(func(value): get("settings").set(property.name, value))
		TYPE_STRING:
			input = LineEdit.new()
			input.text = property.value
			input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			input.text_changed.connect(func(text): get("settings").set(property.name, text))
			
	input_container.add_child(input)
	
	add_child(input_container)


func convert_snake_case_to_title(text: String) -> String:
	var words = text.split("_")
	var capitalized_words = []
	
	for word in words:
		capitalized_words.append(word.capitalize())
	
	return " ".join(capitalized_words)
