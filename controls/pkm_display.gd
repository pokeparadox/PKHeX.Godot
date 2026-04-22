extends Control

func setup(pkm_model : PkmDisplayModel, save_hash : String) -> void:
	%Name.text = pkm_model.nick_name
	%Gender.text = str(pkm_model.gender)
	%Shiny.text = "Shiny: " + str(pkm_model.is_shiny)
	%Gen.text = "Gen: " + str(pkm_model.generation)
	%Level.text = "Lvl: " + str(pkm_model.current_level)
	%EXP.text = "EXP: " + str(pkm_model.experience)
	# Load the sprite from the file hash
	var sprite = await PkHexRest.get_pkm_sprite(pkm_model.file_hash, save_hash)
	%Sprite.texture_normal = sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_delete_button_pressed() -> void:
	# Confirm deletion with user
	
	# Call the Delete API
	
	pass # Replace with function body.
