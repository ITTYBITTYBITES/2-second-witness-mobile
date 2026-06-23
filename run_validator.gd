extends SceneTree
func _init():
    var script = load("res://tools/PreImportAssetValidator.gd").new()
    script._run()
    quit()
