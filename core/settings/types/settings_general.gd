class_name  GeneralSettings
extends Settings


@export_category("StreamerBot")
@export var websocket_url: String = "ws://127.0.0.1:8080"

@export_category("Audio")
@export_range(0, 1) var general_volume: float = 0.5
