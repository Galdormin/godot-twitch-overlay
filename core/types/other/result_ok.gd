class_name Ok
extends Result

var value: Variant

func _init(p_value: Variant):
	value = p_value

func unwrap() -> Variant:
	return value

func unwrap_or(default: Variant) -> Variant:
	return value
