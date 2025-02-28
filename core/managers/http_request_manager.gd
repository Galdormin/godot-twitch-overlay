extends AwaitableHTTPRequest


func request_dict(api_url: String) -> Result:
	var resp = await async_request(api_url)
	if !resp.success() or resp.status_err():
		Loggie.msg("Error when request url " + api_url + ". Code: ", resp.status).error()
		return Err.new("Request has failed. Code: " + resp.status)
	
	var data = resp.body_as_json() as Dictionary
	return Ok.new(data)

func request_png(image_url: String) -> Result:
	var resp = await async_request(image_url)
	if !resp.success() or resp.status_err():
		Loggie.msg("Error when request image on url " + image_url + ". Code: ", resp.status).error()
		return Err.new("Request has failed. Code: " + resp.status)
	
	var image = Image.new()
	var error = image.load_png_from_buffer(resp.bytes)
	if error != OK:
		return Err.new("Couldn't load the image.")
	
	var texture = ImageTexture.create_from_image(image)
	return Ok.new(texture)

func request_ogg(sound_url: String) -> Result:
	var resp = await async_request(sound_url)
	if !resp.success() or resp.status_err():
		Loggie.msg("Error when request sound on url " + sound_url + ". Code: ", resp.status).error()
		return Err.new("Request has failed. Code: " + resp.status)
	
	var sound = AudioStreamOggVorbis.load_from_buffer(resp.bytes)
	return Ok.new(sound)
