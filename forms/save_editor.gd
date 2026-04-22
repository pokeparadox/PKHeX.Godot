extends VBoxContainer

var save_hash : String

func setup(hash : String) -> void:
	save_hash = hash
	await $"HBoxContainer/PKM View 1".load_pkm_listing(hash, Constants.LOCATION.PARTY)
	await $"HBoxContainer/PKM View 2".load_pkm_listing(hash, Constants.LOCATION.BOX)
