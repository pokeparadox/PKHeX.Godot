extends Node

var http_request : HTTPRequest
var base_url : String

const save_file : String = "SaveFile"
const sprite : String = "Sprite"
const RESPONSE_CODE : int = 1
const BODY : int = 3
const BINARY_HEADER : Array[String] = ["Content-Type: application/octet-stream"]
func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	base_url = Settings.base_address

# Load save into server
func load_save_file(path : String) -> bool:
	print("Selected file: ", path)
	var byte_array: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if not byte_array.is_empty():
		var address : String = "/".join([base_url,save_file, "save", "upload"])
		if OK == http_request.request_raw(address, BINARY_HEADER, HTTPClient.METHOD_PUT, byte_array):
			var result = await http_request.request_completed
			match result[RESPONSE_CODE]:
				200:
					return true
				415:
					var error = result[BODY].get_string_from_ascii()
					print("415 Error: ", error)
	return false

# Dump the PKM into server
func dump_party_pkm(save_hash : String) -> Array[String]:
	var address : String = "/".join([base_url, save_file, save_hash, "party", "dump"])
	var r: int = http_request.request(address, [], HTTPClient.METHOD_POST)
	if r == OK:
		var result = await http_request.request_completed
		if result[RESPONSE_CODE] == 200:
			var json_string = result[BODY].get_string_from_utf8()
			var data = JSON.parse_string(json_string)
			if data is Array:
				# Convert to Array[String], filtering out non-strings if needed
				var string_array: Array[String] = []
				for item in data:
					if item is String:
						string_array.append(item)
				return string_array
	return []

	
# Load a PKM file into server
func load_pkm_file(path : String) -> String:
	print("Selected file: ", path)
	var byte_array: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if not byte_array.is_empty():
		var address : String = "/".join([base_url,save_file, "pkm", "upload", path.get_file()])
		if OK == http_request.request_raw(address, BINARY_HEADER, HTTPClient.METHOD_PUT, byte_array):
			var result = await http_request.request_completed
			match result[RESPONSE_CODE]:
				200:
					return result[BODY].get_string_from_ascii()
				415:
					var error = result[BODY].get_string_from_ascii()
					print("415 Error: ", error)
	return ""

# get array of saves
func get_save_listing() -> Array[SaveDisplayModel]:
	var address : String = "/".join([base_url,save_file, "save", "list"])
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		match result[RESPONSE_CODE]:
			200:
				return _convert_to_save_display_array(result[BODY].get_string_from_utf8())
	
	return []

# Delete a save by provided file hash
func delete_save_file(file_hash : String) -> bool:
	var address : String = "/".join([base_url,save_file, "save", file_hash, "delete"])
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		match result[RESPONSE_CODE]:
			200:
				return true
	return false

# Get the number of party PKM
func party_pkm_count(file_hash : String) -> int:
	var address : String = "/".join([base_url,save_file, "party", "count", file_hash])
	return await _http_int_response(address)

# Get the number of Boxes available
func box_count(file_hash : String) -> int:
	var address : String = "/".join([base_url,save_file, "boxes", "count", file_hash])
	return await _http_int_response(address)

# Get the number of PKM in the server storage
func server_pkm_count(file_hash : String) -> int:
	var address : String = "/".join([base_url,save_file, "server", "count", file_hash])
	return await _http_int_response(address)
#  [HttpGet("pkm/{pkmHash}/{saveHash}/sprite")]
func get_pkm_sprite(pkm_hash : String, save_hash : String) -> Texture2D:
	var address : String = "/".join([base_url, sprite, "pkm", pkm_hash, save_hash, "sprite"])
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		match result[RESPONSE_CODE]:
			200:
				var file = _convert_to_file_model(result[BODY].get_string_from_utf8())
				if file != null:	
					var image: Image = Image.new()
					var err: int = image.load_png_from_buffer(file.file_data)
					if err == OK:
						var texture: ImageTexture = ImageTexture.create_from_image(image)
						return texture
	return null


# Display summary listing of PKM in party
func get_pkm_party_display_listing(file_hash : String) -> Array[PkmDisplayModel]:
	var address : String = "/".join([base_url,save_file, "party", "display", file_hash])
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		match result[RESPONSE_CODE]:
			200:
				return _convert_to_pkm_display_array(result[BODY].get_string_from_utf8())
	
	return []

# Display summary listing of PKM in box

# Display summary listing of PKM in server

## Private Helpers
func _http_int_response(address : String) -> int:
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		match result[RESPONSE_CODE]:
			200:
				return int(result[BODY].get_string_from_utf8())
	return -1

func _convert_to_save_display(json) -> SaveDisplayModel:
	if not json.is_empty():
		var model: SaveDisplayModel = SaveDisplayModel.new()
		model.display_string = json["displayString"]
		model.file_hash = json["fileHash"]
		return model
	return null

func _convert_to_save_display_array(json_string : String) -> Array[SaveDisplayModel]:
	var output : Array[SaveDisplayModel]
	var json_data = JSON.parse_string(json_string)
	if json_data != null:
		for json in json_data:
			var m := _convert_to_save_display(json)
			if m != null:
				output.append(m)
	return output
	
func _convert_to_pkm_display(json) -> PkmDisplayModel:
	if not json.is_empty():
		var model: PkmDisplayModel = PkmDisplayModel.new()
		model.nick_name = json["nickname"]
		model.generation = json["generation"]
		model.current_level = json["currentLevel"]
		#model.gender = json["gender"]
		model.experience = json["exp"]
		model.is_shiny = json["isShiny"]
		return model
	return null

func _convert_to_pkm_display_array(json_string : String) -> Array[PkmDisplayModel]:
	var output : Array[PkmDisplayModel]
	var json_data = JSON.parse_string(json_string)
	if json_data != null:
		for json in json_data:
			var m := _convert_to_pkm_display(json)
			if m != null:
				output.append(m)
	return output

func _convert_to_file_model(json_string : String) -> FileModel:
	var output : FileModel
	if not json_string.is_empty():
		var json_data = JSON.parse_string(json_string)
		if json_data != null:
			output = FileModel.new()
			output.file_name = json_data["fileName"]
			output.file_hash = json_data["fileHash"]
			output.file_size = int(json_data["fileSize"])
			output.file_data = Marshalls.base64_to_raw(json_data["fileData"])
	return output
