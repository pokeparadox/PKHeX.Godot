extends PanelContainer

const PkmDisplay = preload("res://controls/pkm_display.tscn")



var location : Constants.LOCATION = Constants.LOCATION.PARTY
var location_index : int = 0

func load_pkm_listing(save_hash : String, loctn : Constants.LOCATION, index : int = 0) -> void:
	location = loctn
	location_index = index
	match location:
		Constants.LOCATION.PARTY:
			load_party_pkm(save_hash)
		Constants.LOCATION.BOX:
			load_box_pkm(location_index)
		Constants.LOCATION.SERVER:
			load_server_pokemon(location_index)

func load_party_pkm(save_hash : String) -> void:
	%BoxName.text = "Party"
	var party: Array[PkmDisplayModel] = await PkHexRest.get_pkm_party_display_listing(save_hash)
	var dump : Array[String] = await PkHexRest.dump_party_pkm(save_hash)
	if dump.size() == party.size():
		for i in range(party.size()):
			party[i].file_hash = dump[i]
	
	load_pkm(party, save_hash)
	
func load_box_pkm(box_index : int) -> void:
	%BoxName.text = "Box #" + str(box_index + 1)
	# get box pkm
	
func load_server_pokemon(page: int, num_pkm: int = 10) -> void:
	pass
	
func load_pkm(pkm : Array[PkmDisplayModel], save_hash : String) -> void:
	for child in %PKMListing.get_children():
		child.queue_free()
	for model in pkm:
		var pkm_scn: Node = PkmDisplay.instantiate()
		await pkm_scn.setup(model, save_hash);
		%PKMListing.add_child(pkm_scn)
