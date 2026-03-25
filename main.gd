extends VBoxContainer

func _on_button_load_save_pressed() -> void:
	var file_dlg = FileDialog.new()
	file_dlg.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dlg.connect("file_selected", _on_file_selected)
	add_child(file_dlg)
	file_dlg.popup_centered()

func _on_file_selected(path: String) -> void:
	if await PkHexRest.load_save_file(path):
		$SaveSelector.refresh_saves()


func _on_save_selector_save_file_chosen(save_file_hash: String) -> void:
	# From the save hash we can now perform 
	pass # Replace with function body.
