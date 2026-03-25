extends Node

var config = ConfigFile.new()
const SETTINGS_PATH = "user://settings.cfg"
var base_address : String

func load_settings() -> void:
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		if not FileAccess.file_exists(SETTINGS_PATH):
			config.set_value("API", "base_address", "http://localhost:9023/api")
			config.save(SETTINGS_PATH)
			
	base_address = config.get_value("API", "base_address", "http://localhost:9023/api")
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()

func _exit_tree() -> void:
	config.save(SETTINGS_PATH)
