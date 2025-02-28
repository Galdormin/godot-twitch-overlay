class_name Err
extends Result

var error: String
	
func _init(p_error: String):
	error = p_error

func unwrap() -> void:
	Loggie.msg("Call unwrap on Err:", error).error()
	assert(false)

func unwrap_or(default: Variant) -> Variant:
	return default
