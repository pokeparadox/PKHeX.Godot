extends VBoxContainer

var save_hash : String

func _ready() -> void:
	# Set initial 50/50 split
	_update_split_offset()
	# Connect to size changes to maintain 50/50 split
	%SplitContainer.resized.connect(_update_split_offset)

func _update_split_offset() -> void:
	%SplitContainer.split_offset = %SplitContainer.size.x / 2

func setup(s_hash : String) -> void:
	save_hash = s_hash
	%"PKM View 1".load_pkm_listing(s_hash, Constants.LOCATION.PARTY)
	%"PKM View 2".load_pkm_listing(s_hash, Constants.LOCATION.BOX)
