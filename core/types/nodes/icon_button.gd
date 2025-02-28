@tool
class_name IconButton
extends TextureButton

@export var texture: Texture:
	set(p_texture):
		texture_normal = p_texture
		texture = p_texture

@export var icon_size: float = 50.0:
	set(p_size):
		custom_minimum_size = Vector2(p_size, p_size)
		icon_size = p_size

var normal_color: Color
var pressed_color: Color
var hover_color: Color
var disabled_color: Color

var _theme_overrides = CustomThemeOverrides.new([
	["normal_color", Theme.DATA_TYPE_COLOR],
	["pressed_color", Theme.DATA_TYPE_COLOR],
	["hover_color", Theme.DATA_TYPE_COLOR],
	["disabled_color", Theme.DATA_TYPE_COLOR]
])


func _ready() -> void:
	_init_button()
	_update_button_color()

func _process(_delta: float) -> void:
	_update_button_color()

func _init_button() -> void:
	# Setup default parameters
	ignore_texture_size = true
	stretch_mode = STRETCH_KEEP_ASPECT_CENTERED
	custom_minimum_size = Vector2(icon_size, icon_size)
	
	# Setup Shader
	material = ShaderMaterial.new()
	material.shader = load("res://resources/shaders/button.gdshader")


func _load_from_theme() -> void:
	normal_color = _get_color("normal_color")
	pressed_color = _get_color("pressed_color")
	hover_color = _get_color("hover_color")
	disabled_color = _get_color("disabled_color")

func _get_color(color_name: StringName):
	if has_theme_color_override(color_name):
		return get_theme_color(color_name)
	else:
		return get_theme_color(color_name, "IconButton")

func _update_button_color() -> void:
	_load_from_theme()
	var p_color = normal_color
	
	if disabled:
		p_color = disabled_color
	elif button_pressed:
		p_color = pressed_color
	elif is_hovered():
		p_color = hover_color
		
	material.set_shader_parameter("target_color", p_color);

func _get_property_list():
	return _theme_overrides.theme_property_list(self)
