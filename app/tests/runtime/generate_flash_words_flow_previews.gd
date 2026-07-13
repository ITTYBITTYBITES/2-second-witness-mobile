extends SceneTree

const OUTPUT_DIR: String = "res://../docs/product/artifacts/flash_words"
const PREVIEW_SIZE := Vector2i(1080, 1920)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	root.size = PREVIEW_SIZE
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await process_frame
	await process_frame
	var runtime: Node = root.get_node("ChallengeSessionService")
	runtime.call("start_family_session", "flash_words", "single_word_v1", "preview", 919191)
	await process_frame
	await process_frame
	var observation: Control = shell.get("_current_screen") as Control
	observation.set_process(false)
	await _save_frame("%s/flash_words_observation_ui.png" % OUTPUT_DIR)
	runtime.call("advance_to_response")
	await process_frame
	await process_frame
	await _save_frame("%s/flash_words_recall_ui.png" % OUTPUT_DIR)
	var instance: ChallengeInstance = runtime.call("get_active_instance")
	runtime.call("submit_response", instance.answer_options[1], 520)
	runtime.call("present_result")
	await process_frame
	await process_frame
	await _save_frame("%s/flash_words_result_ui.png" % OUTPUT_DIR)
	quit(0)

func _save_frame(path: String) -> void:
	RenderingServer.force_draw()
	await process_frame
	var image := root.get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Failed to save %s: %s" % [path, error])
		quit(1)
		return
	print("[FLASH FLOW PREVIEW] %s" % path)
