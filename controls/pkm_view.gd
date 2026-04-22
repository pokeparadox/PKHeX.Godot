extends PanelContainer

const PkmDisplay = preload("res://controls/pkm_display.tscn")



var location : Constants.LOCATION = Constants.LOCATION.PARTY
var location_index : int = 0

func load_pkm_listing(save_hash : String, loctn : Constants.LOCATION, index : int = 0) -> void:
	location = loctn
	location_index = index
	match location:
		Constants.LOCATION.PARTY:
			await load_party_pkm(save_hash)
		Constants.LOCATION.BOX:
			await load_box_pkm(save_hash, location_index)
		Constants.LOCATION.SERVER:
			await load_server_pokemon(location_index)

func load_party_pkm(save_hash : String) -> void:
	%BoxName.text = "Party"
	var party: Array[PkmDisplayModel] = await PkHexRest.get_pkm_party_display_listing(save_hash)
	var dump : Array[String] = await PkHexRest.dump_party_pkm(save_hash)
	if dump.size() == party.size():
		for i in range(party.size()):
			party[i].file_hash = dump[i]
	load_pkm(party, save_hash)
	
func load_box_pkm(save_hash : String, box_index : int) -> void:
	%BoxName.text = "Box #" + str(box_index + 1)
	var box: Array[PkmDisplayModel] = await PkHexRest.get_pkm_box_display_listing(save_hash, box_index)
	var dump : Array[String] = await PkHexRest.dump_box_pkm(save_hash, box_index)
	if dump.size() == box.size():
		for i in range(box.size()):
			box[i].file_hash = dump[i]
	load_pkm(box, save_hash)
	
func load_server_pokemon(page: int, num_pkm: int = 10) -> void:
	pass
	
func load_pkm(pkm : Array[PkmDisplayModel], save_hash : String) -> void:
	for child in %PKMListing.get_children():
		child.queue_free()
	for model in pkm:
		var pkm_scn: Node = PkmDisplay.instantiate()
		await pkm_scn.setup(model, save_hash);
		%PKMListing.add_child(pkm_scn)
