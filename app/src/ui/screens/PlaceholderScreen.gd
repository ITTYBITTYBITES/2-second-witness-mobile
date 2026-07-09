extends Control

@export var route_name: String = "unknown"

func _ready() -> void:
	if not has_node("Center"):
		var center := CenterContainer.new()
		center.name = "Center"
		center.anchor_right = 1.0
		center.anchor_bottom = 1.0
		add_child(center)
		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		center.add_child(vbox)
		var lbl := Label.new()
		lbl.text = "Screen: %s\n(Placeholder)" % route_name
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl)
		var back := Button.new()
		back.text = "Back to Home"
		back.pressed.connect(func():
			if NavigationService:
				NavigationService.navigate_to("home")
		)
		vbox.add_child(back)

func on_navigated_to(params: Dictionary) -> void:
	route_name = params.get("route", route_name)
	print("[PlaceholderScreen] Navigated to %s" % route_name)
