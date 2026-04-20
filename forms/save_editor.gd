extends VBoxContainer

var save_hash : String

func setup(hash : String) -> void:
	save_hash = hash
	$"HBoxContainer/PKM View 1".load_pkm_listing(hash, Constants.LOCATION.PARTY)
	$"HBoxContainer/PKM View 2".load_pkm_listing(hash, Constants.LOCATION.BOX)
