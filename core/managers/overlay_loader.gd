extends Node

const OVERLAY_FOLDER_PATH = "overlays"

var _overlay_list: Array[Overlay] = []
var _overlay_diretory: DirAccess


func _ready() -> void:
	_init_overlay_folder()
	_load_overlays()


func get_overlay_list() -> Array[Overlay]:
	return _overlay_list


func open_overlay_folder() -> void:
	var global_path = ProjectSettings.globalize_path(_overlay_diretory.get_current_dir())
	OS.shell_open(global_path)


func _init_overlay_folder() -> void:
	_overlay_diretory = DirAccess.open("user://")
	if not _overlay_diretory:
		Loggie.msg("An error occurred when trying to access the path.").error()
		return

	if _overlay_diretory.dir_exists(OVERLAY_FOLDER_PATH):
		_overlay_diretory.change_dir(OVERLAY_FOLDER_PATH)
		return
	
	Loggie.msg("Overlay folder not found. Creating a new one.").info()
	_overlay_diretory.make_dir(OVERLAY_FOLDER_PATH)
	_overlay_diretory.change_dir(OVERLAY_FOLDER_PATH)


func _load_overlays() -> void:
	# Load all resource packs in the overlay folder
	_overlay_diretory.list_dir_begin()
	while true:
		var file = _overlay_diretory.get_next()
		if file == "":
			break

		var success = ProjectSettings.load_resource_pack(_overlay_diretory.get_current_dir() + "/" + file)
		if not success:
			Loggie.msg("Failed to load overlay: " + file).error()
			continue

	_overlay_diretory.list_dir_end()

	# Load all overlay resources
	var overlay_folder = DirAccess.open("res://overlay")
	if not overlay_folder:
		Loggie.msg("An error occurred when trying to access the path.").error()
		return
	
	overlay_folder.list_dir_begin()
	while true:
		var file = overlay_folder.get_next()
		if file == "":
			break
		
		var overlay_data = load("res://overlay/" + file + "/overlay.tres")
		_overlay_list.append(overlay_data)

	overlay_folder.list_dir_end()
