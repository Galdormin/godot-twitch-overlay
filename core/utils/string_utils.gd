class_name StringUtils


static func snake_case_to_title(text: String) -> String:
	var words = text.split("_")
	var capitalized_words = []
	
	for word in words:
		capitalized_words.append(word.capitalize())
	
	return " ".join(capitalized_words)


static func title_to_snake_case(text: String) -> String:
	var words = text.split(" ")
	var snake_words = []
	
	for word in words:
		snake_words.append(word.to_lower())
	
	return "_".join(snake_words)