extends Node

var http_request : HTTPRequest
var base_url : String

const save_file : String = "SaveFile"
const RESPONSE_CODE : int = 1
const BODY : int = 3
const BINARY_HEADER : Array[String] = ["Content-Type: application/octet-stream"]
func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	base_url = Settings.base_address

func load_save_file(path : String) -> bool:
	print("Selected file: ", path)
	var byte_array = FileAccess.get_file_as_bytes(path)
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

func get_save_listing() -> Array[SaveDisplayModel]:
	var address : String = "/".join([base_url,save_file, "save", "list"])
	var r = http_request.request(address)
	if r == OK:
		var result = await http_request.request_completed
		match result[RESPONSE_CODE]:
			200:
				return _convert_to_save_display_array(result[BODY].get_string_from_utf8())
	
	return []

## Private Helpers
func _convert_to_save_display(json) -> SaveDisplayModel:
	if not json.is_empty():
		var model = SaveDisplayModel.new()
		model.displayString = json["displayString"]
		model.fileHash = json["fileHash"]
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
