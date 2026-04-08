extends VBoxContainer

const PkmDisplay = preload("res://controls/pkm_display.tscn")

enum LOCATION
{
	PARTY,
	BOX,
	SERVER
}

var location : LOCATION = LOCATION.PARTY
var location_index : int = 0

func load_pkm_listing(save_hash : String, loctn : LOCATION, index : int = 0) -> void:
	location = loctn
	location_index = index
	match location:
		LOCATION.PARTY:
			load_party_pkm(save_hash)
		LOCATION.BOX:
			load_box_pkm(location_index)
		LOCATION.SERVER:
			load_server_pokemon(location_index)

func load_party_pkm(save_hash : String) -> void:
	$BoxName.text = "Party"
	var party: Array[PkmDisplayModel] = await PkHexRest.get_pkm_party_display_listing(save_hash)
	var dump = await PkHexRest.dump_party_pkm(save_hash)
	load_pkm(party)
	
func load_box_pkm(box_index : int) -> void:
	pass
	
func load_server_pokemon(page: int, num_pkm: int = 10) -> void:
	pass
	
func load_pkm(pkm : Array[PkmDisplayModel]) -> void:
	for child in $PKMListing.get_children():
		child.queue_free()
	for model in pkm:
		var pkm_scn = PkmDisplay.instantiate()
		pkm_scn.setup(model);
		$PKMListing.add_child(pkm_scn)
