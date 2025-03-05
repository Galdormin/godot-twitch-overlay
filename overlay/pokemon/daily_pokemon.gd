extends Control

class Pokemon:
	var name: String
	var cry_url: String
	var default_url: String
	var shiny_url: String
	
	func get_image_url(is_shiny: bool):
		if is_shiny:
			return shiny_url
		
		return default_url

const NB_POKEMON = 1025 #TODO: Put in settings
const SHINY_RATE = 512 #TODO: Put in settings

@onready var display_timer = $DisplayTimer

@onready var pokemon_container = $PokemonContainer
@onready var pokemon_image = %PokemonImage
@onready var pokemon_label = %PokemonLabel
@onready var pokemon_audio = $AudioStreamPlayer

var is_active: bool = false

func _ready() -> void:
	pokemon_container.hide()
	StreamerBotManager.command_received.connect(_on_command_received)

func request_pokemon(user: TwitchUser):
	if is_active:
		Loggie.msg("Request pokemon failed because already active.").warn()
		return
	
	is_active = true
	var hash_val = _get_daily_hash(user)
	var poke_id = hash_val % 1025 + 1
	var is_shiny = (hash_val / 1025) % 512 == 0
	
	# Request Pokemon
	var pokemon = await _get_pokemon_data(poke_id)
	if not pokemon:
		Loggie.msg("Could not find the pokemon. poke_id: ", poke_id).error()
		return
	
	pokemon_label.text = "Aujourd'hui " + user.username + " est " + pokemon.name
	
	# Request cry
	var cry_stream = await HttpRequestManager.request_ogg(pokemon.cry_url)
	if cry_stream is Ok:
		pokemon_audio.stream = cry_stream.unwrap()
		pokemon_audio.volume_db = linear_to_db(SettingsManager.settings.pokemon.pokemon_volume)
	else:
		Loggie.msg("Request pokemon", poke_id, "without cry.").warn()
	
	# Request image
	var image_texture = await HttpRequestManager.request_png(pokemon.get_image_url(is_shiny))
	if image_texture is Err:
		Loggie.msg("Couldn't request Pokemon image. Err:", image_texture.error)
		return
	
	pokemon_image.texture = image_texture.unwrap()
	start_animation()

func start_animation():
	pokemon_container.set_indexed("modulate:a", 1)
	pokemon_container.show()
	display_timer.start()
	pokemon_audio.play()

func fade_animation():
	var tween = get_tree().create_tween()
	tween.tween_property(pokemon_container, "modulate:a", 0, 1)
	tween.tween_callback(stop_animation)

func stop_animation():
	is_active = false
	pokemon_container.hide()

func _get_pokemon_data(poke_id: int) -> Pokemon:
	# Request Pokemon data
	var data = await HttpRequestManager.request_dict("https://pokeapi.co/api/v2/pokemon/" + str(poke_id))
	if data is Err:
		return null
	
	var poke_data = data.unwrap()
	
	# Request Species
	data = await HttpRequestManager.request_dict(poke_data["species"]["url"])
	if data is Err:
		return null
	
	var species_data = data.unwrap()
	
	# Create Pokemon
	var pokemon = Pokemon.new()
	pokemon.name = species_data["names"][4]["name"]
	pokemon.cry_url = poke_data["cries"]["latest"]
	pokemon.default_url = poke_data["sprites"]["other"]["official-artwork"]["front_default"]
	pokemon.shiny_url = poke_data["sprites"]["other"]["official-artwork"]["front_shiny"]
	
	return pokemon

func _get_daily_hash(user: TwitchUser) -> int:
	var date = Time.get_date_string_from_system()
	
	var hash_data = date + user.username
	var hash_val = hash_data.md5_buffer().slice(0, 8).decode_u64(0)
	
	if hash_val < 0:
		return -hash_val
	
	return hash_val

#region Signals

func _on_command_received(command_name: String, user: TwitchUser):
	if command_name != SettingsManager.settings.pokemon.pokemon_command:
		return
	
	request_pokemon(user)

func _on_display_timer_timeout() -> void:
	fade_animation()

#endregion
