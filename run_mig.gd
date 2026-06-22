extends SceneTree

func _init():
	var script = load("res://tools/DataMigrationTool.gd").new()
	script._run()
	quit()
