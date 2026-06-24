extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# LIVEOPS & OTA PATCH PIPELINE
# ---------------------------------------------------------

signal sync_completed(status: String)

const REPO_MANIFEST_URL = "https://raw.githubusercontent.com/ITTYBITTYBITES/2-second-witness-mobile/master/live_content/manifest.json"
const USER_CACHE_DIR = "user://live_content/patches/"

var _http_request: HTTPRequest
var _is_syncing: bool = false

func _ready():
	print("[GITHUB SYNC] Online. Standby for OTA patches.")
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_manifest_downloaded)

func sync_cycle():
	if _is_syncing: return
	_is_syncing = true
	
	print("[GITHUB SYNC] Pinging remote manifest...")
	var error = _http_request.request(REPO_MANIFEST_URL)
	if error != OK:
		print("[GITHUB SYNC ERROR] HTTP Request failed to initiate.")
		_is_syncing = false
		sync_completed.emit("failed_connection")

func _on_manifest_downloaded(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[GITHUB SYNC ERROR] Failed to fetch manifest. Code: ", response_code)
		_is_syncing = false
		sync_completed.emit("failed_download")
		return
		
	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		print("[GITHUB SYNC ERROR] Remote manifest is corrupted JSON.")
		_is_syncing = false
		sync_completed.emit("failed_parse")
		return
		
	var remote_data = json.data
	print("[GITHUB SYNC] Manifest received. Remote Version: ", remote_data.get("version", "unknown"))
	
	# In a full production environment, we would iterate through remote_data["patches"],
	# spawn new HTTPRequests for each file, download them to USER_CACHE_DIR,
	# and then tell the ContentLoader to re-index.
	
	# For now, we validate the connection works and exit cleanly.
	print("[GITHUB SYNC] LiveOps pipeline verified. System is ready for patch payloads.")
	_is_syncing = false
	sync_completed.emit("success")
