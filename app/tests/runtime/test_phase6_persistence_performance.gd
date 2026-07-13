extends SceneTree
## Production-readiness checks for atomic persistence, recovery, local analytics,
## packaged audio, and bounded local performance.

var failures: Array[String] = []
var passes := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[PHASE6-SYSTEM PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[PHASE6-SYSTEM FAIL] %s" % message)

func _run() -> void:
	var config: Node = root.get_node("ConfigService")
	var save: Node = root.get_node("SaveService")
	var settings: Node = root.get_node("SettingsService")
	var analytics: Node = root.get_node("AnalyticsService")
	var audio: Node = root.get_node("AudioService")
	config.call("initialize")
	save.call("initialize")
	settings.call("initialize")
	analytics.call("initialize")
	audio.call("initialize")

	_check(str(config.call("get_value", "environment", "")) == "production", "Production environment is the packaged default")
	_check(not bool(config.call("get_value", "content.auto_update", true)), "Packaged content is offline-first")
	_check(str(config.call("get_value", "content.base_url", "invalid")).is_empty(), "No inactive remote content endpoint ships")

	var path := "user://phase6_atomic_test.json"
	save.call("delete_save", path)
	var started := Time.get_ticks_usec()
	_check(bool(save.call("save_json", path, {"generation": 1, "name": "first"})), "First atomic save succeeds")
	_check(bool(save.call("save_json", path, {"generation": 2, "name": "second"})), "Replacement atomic save succeeds")
	var save_duration_ms := float(Time.get_ticks_usec() - started) / 1000.0
	_check(FileAccess.file_exists(path + ".bak"), "Previous valid save is retained as a recovery copy")
	var loaded: Dictionary = save.call("load_json", path, {})
	_check(int(loaded.get("generation", 0)) == 2, "Latest atomic save loads")

	var corrupt := FileAccess.open(path, FileAccess.WRITE)
	if corrupt:
		corrupt.store_string("{not valid json")
		corrupt.close()
	var recovered: Dictionary = save.call("load_json", path, {})
	_check(int(recovered.get("generation", 0)) == 1, "Corrupt primary save recovers from the verified local backup")
	_check(int((save.call("load_json", path, {}) as Dictionary).get("generation", 0)) == 1, "Recovered save is restored as the new primary")

	var legacy_path := "user://phase6_legacy_test.json"
	var legacy := FileAccess.open(legacy_path, FileAccess.WRITE)
	if legacy:
		legacy.store_string(JSON.stringify({"version": 1, "data": {"player_name": "Legacy Witness"}}))
		legacy.close()
	var migrated: Dictionary = save.call("load_json", legacy_path, {})
	_check(str(migrated.get("display_name", "")) == "Legacy Witness", "Version-one player name migrates to display name")
	_check(not migrated.has("player_name") and int(migrated.get("version", 0)) == 2, "Migration removes legacy keys and records the current data version")
	_check(save_duration_ms < 100.0, "Two local atomic saves complete within 100 ms")

	analytics.call("set_enabled", false)
	analytics.call("log_event", "must_not_persist", {})
	_check((analytics.call("get_buffered_events") as Array).is_empty(), "Analytics opt-out records no local events")
	_check(not FileAccess.file_exists("user://analytics_buffer.jsonl"), "Analytics opt-out clears the local event file")
	analytics.call("set_enabled", true)
	analytics.call("log_event", "phase6_local_event", {"local": true})
	var local_events: Array = analytics.call("get_buffered_events")
	var found_local_event := false
	for event_value: Variant in local_events:
		if event_value is Dictionary and str((event_value as Dictionary).get("event", "")) == "phase6_local_event":
			found_local_event = true
	_check(found_local_event and local_events.size() <= 200, "Enabled analytics keeps bounded local events")

	var cache_value: Variant = audio.get("_stream_cache")
	var cache: Dictionary = cache_value if cache_value is Dictionary else {}
	_check(cache.size() >= 14, "Packaged audio cues are preloaded once")
	var ui_stream: Variant = audio.call("_get_stream_for_id", "ui_click")
	_check(ui_stream is AudioStream, "Packaged interface audio resolves after initialization")
	audio.call("stop_all")
	audio.set("_stream_cache", {})
	ui_stream = null
	await process_frame
	await process_frame

	var memory_mb := float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0
	_check(memory_mb < 220.0, "Headless initialized memory remains below the 220 MB readiness ceiling")

	save.call("delete_save", path)
	save.call("delete_save", legacy_path)
	analytics.call("clear_buffer")
	print("[PHASE6-SYSTEM SUMMARY] %d passed, %d failed, save_ms=%.2f memory_mb=%.1f" % [passes, failures.size(), save_duration_ms, memory_mb])
	quit(0 if failures.is_empty() else 1)
