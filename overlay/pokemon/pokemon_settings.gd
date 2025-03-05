class_name  PokemonSettings
extends Settings


@export_category("StreamerBot")
@export var pokemon_command: String = "!pkmn"

@export_category("Overlay")
@export_range(0, 1) var pokemon_volume: float = 0.5
