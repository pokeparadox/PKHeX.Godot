extends Node

#var http_request : HTTPRequest
const POOLED_REQUESTS : int = 10
var request_pool : Array = []
var base_url : String

const save_file : String = "SaveFile"
const sprite : String = "Sprite"
const RESPONSE_CODE : int = 1
const BODY : int = 3
const BINARY_HEADER : Array[String] = ["Content-Type: application/octet-stream"]

func _ready():
	base_url = Settings.base_address
	for i in range(POOLED_REQUESTS):  # Create a pool of HTTPRequest instances
		var request: HTTPRequest = HTTPRequest.new()
		add_child(request)
		request_pool.append(request)

# Load save into server
func load_save_file(path : String) -> bool:
	print("Selected file: ", path)
	var byte_array: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if not byte_array.is_empty():
		var address : String = "/".join([base_url,save_file, "save", "upload"])
		var http_request: HTTPRequest = _get_http_request()
		if OK == http_request.request_raw(address, BINARY_HEADER, HTTPClient.METHOD_PUT, byte_array):
			var result = await http_request.request_completed
			_return_http_request(http_request)
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
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address, [], HTTPClient.METHOD_POST)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
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

# Dump the PKM into server
func dump_box_pkm(save_hash : String, index : int) -> Array[String]:
	var address : String = "/".join([base_url, save_file, save_hash, "box", str(index), "dump"])
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address, [], HTTPClient.METHOD_POST)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
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
		var http_request: HTTPRequest = _get_http_request()
		if OK == http_request.request_raw(address, BINARY_HEADER, HTTPClient.METHOD_PUT, byte_array):
			var result = await http_request.request_completed
			_return_http_request(http_request)
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
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
		match result[RESPONSE_CODE]:
			200:
				return _convert_to_save_display_array(result[BODY].get_string_from_utf8())
	
	return []

# Delete a save by provided file hash
func delete_save_file(file_hash : String) -> bool:
	var address : String = "/".join([base_url,save_file, "save", file_hash, "delete"])
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
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
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
		match result[RESPONSE_CODE]:
			200:
				var file: FileModel = _convert_to_file_model(result[BODY].get_string_from_utf8())
				if file != null:	
					var image: Image = Image.new()
					var err: int = image.load_png_from_buffer(file.file_data)
					if err == OK:
						var texture: ImageTexture = ImageTexture.create_from_image(image)
						return texture
	return null


# Display summary listing of PKM in party
func get_pkm_party_display_listing(file_hash : String) -> Array[PkmDisplayModel]:
	var address : String = "/".join([base_url,save_file, "party", file_hash, "display"])
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
		match result[RESPONSE_CODE]:
			200:
				return _convert_to_pkm_display_array(result[BODY].get_string_from_utf8())
	
	return []
# [HttpGet("box/{fileHash}/{index}/display")]
# Display summary listing of PKM in box
func get_pkm_box_display_listing(file_hash : String, box_index : int) -> Array[PkmDisplayModel]:
	var address : String = "/".join([base_url,save_file, "box", file_hash, str(box_index), "display"])
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
		match result[RESPONSE_CODE]:
			200:
				return _convert_to_pkm_display_array(result[BODY].get_string_from_utf8())
	
	return []

# Display summary listing of PKM in server

## Private Helpers
func _http_int_response(address : String) -> int:
	var http_request: HTTPRequest = _get_http_request()
	var r: int = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		_return_http_request(http_request)
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
		model.gender = json["gender"]
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

func _get_http_request() -> HTTPRequest:
	if request_pool.size() > 0:
		return request_pool.pop_back()
	else:
		var new_request: HTTPRequest = HTTPRequest.new()
		add_child(new_request)
		return new_request
		
func _return_http_request(request: HTTPRequest) -> void:
	request_pool.append(request)
