extends SceneTree

var failures:Array[String]=[]
var passes:=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,msg:String)->void:
	if ok:passes+=1;print("[INTERACTION PASS] ",msg)
	else:failures.append(msg);push_error("[INTERACTION FAIL] "+msg)
func run()->void:
	var registry:Node=root.get_node("InteractionAdapterRegistry");registry.initialize()
	var ids:Array[String]=registry.get_adapter_ids();check(ids==["multiple_choice","ordering","region_selection","sequence_input","single_choice","spatial_tap"],"Six generic adapters register from content manifest");check((registry.get_future_modes() as Array).has("drag_drop"),"Drag and Drop remains future-registerable")
	for id:String in ids:
		var adapter:InteractionAdapter=registry.create_adapter(id);check(adapter!=null and adapter.get_adapter_id()==id,"Adapter resolves generically: "+id)
	var valid:=InteractionProfile.new({"profile_id":"test.sequence","mode":"sequence_input","adapter_id":"sequence_input"});check(valid.is_contract_valid(),"InteractionProfile validates without family identity")
	var host:=VBoxContainer.new();root.add_child(host)
	var single:InteractionAdapter=registry.create_adapter("single_choice");single.configure(InteractionProfile.default_single_choice(),{"answer_options":["A","B"]});var captured:Array=[null];single.interaction_submitted.connect(func(v):captured[0]=v);single.mount(host);check(host.get_child_count()==2,"Single Choice mounts direct compatible buttons");(host.get_child(1) as Button).emit_signal("pressed");check(captured[0]=="B","Single Choice emits an uninterpreted payload");single.unmount();await process_frame
	var multi:InteractionAdapter=registry.create_adapter("multiple_choice");multi.configure(InteractionProfile.new({"profile_id":"test.multi","mode":"multiple_choice","adapter_id":"multiple_choice"}),{"answer_options":["A","B","C"]});var multi_value:Array=[null];multi.interaction_submitted.connect(func(v):multi_value[0]=v);multi.mount(host);(host.get_child(1) as CheckButton).button_pressed=true;(host.get_child(3) as CheckButton).button_pressed=true;(host.get_child(4) as Button).emit_signal("pressed");check(multi_value[0]==["A","C"],"Multiple Choice emits a selected set without scoring it");multi.unmount();await process_frame
	var scene:=load("res://src/ui/screens/MemoryQuestionScreen.tscn") as PackedScene;var screen:=scene.instantiate() as Control;root.add_child(screen);check(screen.has_method("_on_interaction_submitted"),"Established Recall route is now a generic interaction host");screen.queue_free();host.queue_free();await process_frame
	print("[INTERACTION SUMMARY] %d passed, %d failed"%[passes,failures.size()]);quit(0 if failures.is_empty() else 1)
