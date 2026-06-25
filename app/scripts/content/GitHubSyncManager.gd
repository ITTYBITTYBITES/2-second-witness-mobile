extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# LIVEOPS & DETERMINISTIC CONTENT SYNCHRONIZATION
# ---------------------------------------------------------

signal sync_completed(status: String)

const REPO_MANIFEST_URL = "https://raw.githubusercontent.com/ITTYBITTYBITES/2-second-witness-mobile/master/live_content/manifest.json"
const USER_CACHE_DIR = "user://live_content/"
const LOCAL_MANIFEST_PATH = "user://live_content/manifest.json"

var _http_request: HTTPRequest
var _patch_request: HTTPRequest
var _is_syncing: bool = false
var _active_manifest_version: String = "1.0.0"
var _pending_patches: Array = []
var _current_manifest_payload: Dictionary = {}

func _ready():
	print("[GITHUB SYNC] Online. Guarding deterministic boundaries.")
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_manifest_downloaded)
	
	_patch_request = HTTPRequest.new()
	add_child(_patch_request)
	_patch_request.request_completed.connect(_on_patch_downloaded)
	
	_load_local_manifest_version()

func get_active_content_version() -> String:
	return _active_manifest_version

func sync_cycle():
	if _is_syncing: return
	_is_syncing = true
	
	print("[GITHUB SYNC] Pinging remote manifest...")
	var error = _http_request.request(REPO_MANIFEST_URL)
	if error != OK:
		print("[GITHUB SYNC ERROR] HTTP Request failed to initiate. Offline-First integrity preserved.")
		_is_syncing = false
		sync_completed.emit("failed_connection")

func _on_manifest_downloaded(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[GITHUB SYNC ERROR] Failed to fetch manifest. Offline-First integrity preserved.")
		_is_syncing = false
		sync_completed.emit("failed_download")
		return
		
	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		print("[GITHUB SYNC FATAL] Remote manifest is corrupted JSON. Rejecting payload.")
		_is_syncing = false
		sync_completed.emit("failed_parse")
		return
		
	var remote_data = json.data
	var remote_version = remote_data.get("version", "1.0.0")
	
	if _is_version_greater(remote_version, _active_manifest_version):
		print("[GITHUB SYNC] New Content Version detected: ", remote_version)
		
		# Begin OTA Download Pipeline
		_current_manifest_payload = remote_data
		_pending_patches = remote_data.get("patches", [])
		
		# Create local directory if it doesn't exist
		if not DirAccess.dir_exists_absolute(USER_CACHE_DIR + "patches/"):
			DirAccess.make_dir_recursive_absolute(USER_CACHE_DIR + "patches/")
			
		_download_next_patch()
	else:
		print("[GITHUB SYNC] Local cache is up-to-date. Content version: ", _active_manifest_version)
		_is_syncing = false
		sync_completed.emit("success")

func _download_next_patch():
	if _pending_patches.is_empty():
		_apply_patches_and_lock_version(_current_manifest_payload)
		return
		
	var patch = _pending_patches.pop_front()
	var url = patch.get("url", "")
	var target_path = USER_CACHE_DIR + "patches/" + patch.get("id", "unknown.json") + ".json"
	
	print("[GITHUB SYNC] Downloading patch: ", url)
	_patch_request.download_file = target_path
	var error = _patch_request.request(url)
	
	if error != OK:
		print("[GITHUB SYNC FATAL] Patch download failed to initiate. Aborting OTA update.")
		_is_syncing = false
		sync_completed.emit("failed_patch_download")

func _on_patch_downloaded(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[GITHUB SYNC FATAL] Patch download failed. Code: ", response_code, ". Aborting OTA update.")
		_is_syncing = false
		sync_completed.emit("failed_patch_download")
		return
		
	# Loop until the array is empty
	_download_next_patch()

func _apply_patches_and_lock_version(manifest_data: Dictionary):
	var file = FileAccess.open(LOCAL_MANIFEST_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest_data, "\t"))
		file.close()
		_active_manifest_version = manifest_data.get("version", "1.0.0")
		print("[GITHUB SYNC] Immutable Cache Updated. System locked to version: ", _active_manifest_version)
		_is_syncing = false
		sync_completed.emit("success")
	else:
		print("[GITHUB SYNC FATAL] Failed to write manifest to disk.")
		_is_syncing = false
		sync_completed.emit("failed_write")

func _load_local_manifest_version():
	if FileAccess.file_exists(LOCAL_MANIFEST_PATH):
		var file = FileAccess.open(LOCAL_MANIFEST_PATH, FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var data = json.get_data()
				if typeof(data) == TYPE_DICTIONARY:
					_active_manifest_version = data.get("version", "1.0.0")
			file.close()
	print("[GITHUB SYNC] Engine bound to Content Version: ", _active_manifest_version)

func _is_version_greater(new_ver: String, old_ver: String) -> bool:
	var n = new_ver.split(".")
	var o = old_ver.split(".")
	for i in range(min(n.size(), o.size())):
		if n[i].to_int() > o[i].to_int(): return true
		if n[i].to_int() < o[i].to_int(): return false
	return n.size() > o.size()
