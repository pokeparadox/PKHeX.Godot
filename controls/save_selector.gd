extends VBoxContainer

signal save_file_chosen(save : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_saves()
	
func refresh_saves() -> void:
	var saves : Array[SaveDisplayModel] = await PkHexRest.get_save_listing()
	create_buttons(saves)
	
func create_buttons(saves : Array[SaveDisplayModel]):
	for child in get_children():
		child.queue_free()
	for model in saves:
		var button: Button = Button.new()
		button.text = model.display_string
		button.connect("pressed", _on_button_pressed.bind(model.file_hash))
		add_child(button)
		# TODO add delete buttons within a HBoxContainer

func _on_button_pressed(file_hash : String) -> void:
	emit_signal("save_file_chosen", file_hash)
