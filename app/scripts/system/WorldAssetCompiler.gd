extends Node
class_name WorldAssetCompiler

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# WORLD ASSET COMPILER (DETERMINISTIC PIPELINE SERVICE)
# ---------------------------------------------------------

static func validate_descriptor(descriptor: Dictionary) -> bool:
	if not descriptor.has("identity") or not descriptor.has("determinism"):
		push_error("[COMPILER FATAL] WorldDescriptor missing required identity or determinism keys.")
		return false
		
	var det = descriptor.get("determinism", {})
	if not det.has("seed") or det.get("seed", 0) == 0:
		var ident = descriptor.get("identity", {})
		var u_id = str(ident.get("universe_id", ""))
		var w_id = str(ident.get("world_id", ""))
		if u_id == "" or w_id == "":
			push_error("[COMPILER FATAL] WorldDescriptor missing identity and seed. Cannot deterministically compile world.")
			return false
		var fallback_seed = (u_id + "_" + w_id).hash()
		det["seed"] = fallback_seed
		descriptor["determinism"] = det
		print("[COMPILER WARNING] Missing or zero seed in WorldDescriptor. Clamped to deterministic identity hash: ", fallback_seed)
		
	var vis = descriptor.get("visual_profile", {})
	if vis.has("fog_density"):
		vis["fog_density"] = clampf(float(vis["fog_density"]), 0.0, 2.0)
	if vis.has("contrast"):
		vis["contrast"] = clampf(float(vis["contrast"]), 0.5, 2.0)
	descriptor["visual_profile"] = vis
	
	var iris = descriptor.get("iris_profile", {})
	if iris.has("complexity"):
		iris["complexity"] = clamp(int(iris["complexity"]), 1, 5)
	descriptor["iris_profile"] = iris
	
	return true

static func _sanitize_for_json(data: Variant) -> Variant:
	if typeof(data) == TYPE_DICTIONARY:
		var clean_dict = {}
		var keys = data.keys()
		keys.sort()
		for k in keys:
			clean_dict[k] = _sanitize_for_json(data[k])
		return clean_dict
	elif typeof(data) == TYPE_ARRAY:
		var clean_array = []
		for item in data:
			clean_array.append(_sanitize_for_json(item))
		return clean_array
	elif typeof(data) == TYPE_COLOR:
		return data.to_html(false)
	else:
		return data

static func compute_hash(descriptor: Dictionary) -> int:
	var clean_dict = _sanitize_for_json(descriptor)
	var json_str = JSON.stringify(clean_dict)
	return json_str.hash()

static func cache_exists(hash_val: int, expected_version: String = "") -> bool:
	var dir_path = "user://world_cache/" + str(hash_val) + "/"
	if not DirAccess.dir_exists_absolute(dir_path):
		return false
		
	if not FileAccess.file_exists(dir_path + "bundle.json"):
		return false
		
	if expected_version != "":
		var file = FileAccess.open(dir_path + "bundle.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var data = json.get_data()
				if typeof(data) == TYPE_DICTIONARY:
					var cached_version = data.get("content_version", "")
					if cached_version != expected_version:
						file.close()
						print("[COMPILER] Cache version mismatch for hash ", hash_val, ". Invalidating cache.")
						invalidate_cache(hash_val)
						return false
			file.close()
			
	return true

static func invalidate_cache(hash_val: int):
	var dir_path = "user://world_cache/" + str(hash_val) + "/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name)
			file_name = dir.get_next()
		dir.remove(dir_path)

static func generate_noise(descriptor: Dictionary) -> ImageTexture:
	var det = descriptor.get("determinism", {})
	var seed_val = det.get("seed", 12345)
	
	var vis = descriptor.get("visual_profile", {})
	var noise_prof = vis.get("noise_profile", {})
	var n_type = noise_prof.get("type", "perlin")
	var n_scale = float(noise_prof.get("scale", 4.0))
	
	var noise = FastNoiseLite.new()
	noise.seed = seed_val
	
	if n_type == "simplex":
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	elif n_type == "cellular":
		noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	else:
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		
	noise.frequency = 0.05 * n_scale
	
	var img = noise.get_image(256, 256, false)
	return ImageTexture.create_from_image(img)

static func generate_iris_mesh(descriptor: Dictionary) -> ArrayMesh:
	var iris = descriptor.get("iris_profile", {})
	var base_shape = iris.get("base_shape", "ring")
	var complexity = int(iris.get("complexity", 1))
	var det = descriptor.get("determinism", {})
	var _seed_val = det.get("seed", 12345)
	
	var vertices = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	var segments = 16 * complexity
	var radius_outer = 4.0
	var radius_inner = 3.0
	
	if base_shape == "gear":
		var _teeth = 8 * complexity
		for i in range(segments):
			var angle1 = (float(i) / segments) * TAU
			var angle2 = (float(i + 1) / segments) * TAU
			
			var is_tooth = (i % 2) == 0
			var current_outer = radius_outer + (0.5 if is_tooth else 0.0)
			
			var p1_inner = Vector3(cos(angle1) * radius_inner, sin(angle1) * radius_inner, 0)
			var p1_outer = Vector3(cos(angle1) * current_outer, sin(angle1) * current_outer, 0)
			var p2_inner = Vector3(cos(angle2) * radius_inner, sin(angle2) * radius_inner, 0)
			var p2_outer = Vector3(cos(angle2) * current_outer, sin(angle2) * current_outer, 0)
			
			var base_idx = vertices.size()
			vertices.push_back(p1_inner)
			vertices.push_back(p1_outer)
			vertices.push_back(p2_outer)
			vertices.push_back(p2_inner)
			
			uvs.push_back(Vector2(0, 0))
			uvs.push_back(Vector2(1, 0))
			uvs.push_back(Vector2(1, 1))
			uvs.push_back(Vector2(0, 1))
			
			indices.push_back(base_idx)
			indices.push_back(base_idx + 1)
			indices.push_back(base_idx + 2)
			
			indices.push_back(base_idx)
			indices.push_back(base_idx + 2)
			indices.push_back(base_idx + 3)
			
	elif base_shape == "torus":
		var tube_segments = 6
		var tube_radius = 0.5
		for i in range(segments):
			var a1 = (float(i) / segments) * TAU
			var a2 = (float(i + 1) / segments) * TAU
			for j in range(tube_segments):
				var ta1 = (float(j) / tube_segments) * TAU
				var ta2 = (float(j + 1) / tube_segments) * TAU
				
				var v1 = Vector3((radius_outer + cos(ta1)*tube_radius)*cos(a1), (radius_outer + cos(ta1)*tube_radius)*sin(a1), sin(ta1)*tube_radius)
				var v2 = Vector3((radius_outer + cos(ta2)*tube_radius)*cos(a1), (radius_outer + cos(ta2)*tube_radius)*sin(a1), sin(ta2)*tube_radius)
				var v3 = Vector3((radius_outer + cos(ta1)*tube_radius)*cos(a2), (radius_outer + cos(ta1)*tube_radius)*sin(a2), sin(ta1)*tube_radius)
				var v4 = Vector3((radius_outer + cos(ta2)*tube_radius)*cos(a2), (radius_outer + cos(ta2)*tube_radius)*sin(a2), sin(ta2)*tube_radius)
				
				var base_idx = vertices.size()
				vertices.push_back(v1)
				vertices.push_back(v2)
				vertices.push_back(v4)
				vertices.push_back(v3)
				
				uvs.push_back(Vector2(0, 0))
				uvs.push_back(Vector2(1, 0))
				uvs.push_back(Vector2(1, 1))
				uvs.push_back(Vector2(0, 1))
				
				indices.push_back(base_idx)
				indices.push_back(base_idx + 1)
				indices.push_back(base_idx + 2)
				indices.push_back(base_idx)
				indices.push_back(base_idx + 2)
				indices.push_back(base_idx + 3)
				
	else:
		for i in range(segments):
			var angle1 = (float(i) / segments) * TAU
			var angle2 = (float(i + 1) / segments) * TAU
			
			var p1_inner = Vector3(cos(angle1) * radius_inner, sin(angle1) * radius_inner, 0)
			var p1_outer = Vector3(cos(angle1) * radius_outer, sin(angle1) * radius_outer, 0)
			var p2_inner = Vector3(cos(angle2) * radius_inner, sin(angle2) * radius_inner, 0)
			var p2_outer = Vector3(cos(angle2) * radius_outer, sin(angle2) * radius_outer, 0)
			
			var base_idx = vertices.size()
			vertices.push_back(p1_inner)
			vertices.push_back(p1_outer)
			vertices.push_back(p2_outer)
			vertices.push_back(p2_inner)
			
			uvs.push_back(Vector2(0, 0))
			uvs.push_back(Vector2(1, 0))
			uvs.push_back(Vector2(1, 1))
			uvs.push_back(Vector2(0, 1))
			
			indices.push_back(base_idx)
			indices.push_back(base_idx + 1)
			indices.push_back(base_idx + 2)
			
			indices.push_back(base_idx)
			indices.push_back(base_idx + 2)
			indices.push_back(base_idx + 3)
			
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

static func generate_audio(descriptor: Dictionary) -> AudioStreamWAV:
	var aud = descriptor.get("audio_profile", {})
	var base_freq = float(aud.get("base_freq", 440.0))
	var harmonics = int(aud.get("harmonics", 3))
	var det = descriptor.get("determinism", {})
	var seed_val = det.get("seed", 12345)
	
	var sample_rate = 22050
	var duration = 1.0
	var sample_count = int(sample_rate * duration)
	
	var buffer = PackedByteArray()
	buffer.resize(sample_count * 2)
	
	var phase_offsets = []
	for h in range(harmonics):
		phase_offsets.append(float((seed_val + h * 997) % 1000) / 1000.0 * TAU)
		
	for i in range(sample_count):
		var time = float(i) / sample_rate
		var sample_val = 0.0
		
		for h in range(harmonics):
			var freq = base_freq * (h + 1)
			var amplitude = 1.0 / float(h + 1)
			sample_val += sin(time * freq * TAU + phase_offsets[h]) * amplitude
			
		sample_val = clampf(sample_val / float(harmonics), -1.0, 1.0)
		var int_val = int(sample_val * 32767.0)
		
		buffer[i * 2] = int_val & 0xFF
		buffer[i * 2 + 1] = (int_val >> 8) & 0xFF
		
	var wav = AudioStreamWAV.new()
	wav.data = buffer
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = sample_count
	return wav

static func pack(world_id: String, hash_val: int, noise_tex: ImageTexture, iris_mesh: ArrayMesh, audio_wav: AudioStreamWAV, content_version: String) -> Dictionary:
	var dir_path = "user://world_cache/" + str(hash_val) + "/"
	return {
		"world_id": world_id,
		"hash": hash_val,
		"content_version": content_version,
		"textures": {"bg_noise": noise_tex, "bg_noise_path": dir_path + "noise.png"},
		"meshes": {"iris_accent": iris_mesh, "iris_accent_path": dir_path + "iris.tres"},
		"audio": {"audio_overlay": audio_wav, "audio_overlay_path": dir_path + "audio.tres"}
	}

static func write_cache(bundle: Dictionary):
	var hash_val = bundle["hash"]
	var dir_path = "user://world_cache/" + str(hash_val) + "/"
	
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
		
	var noise_tex: ImageTexture = bundle["textures"]["bg_noise"]
	if noise_tex:
		noise_tex.get_image().save_png(dir_path + "noise.png")
		
	var iris_mesh: ArrayMesh = bundle["meshes"]["iris_accent"]
	if iris_mesh:
		ResourceSaver.save(iris_mesh, dir_path + "iris.tres")
		
	var audio_wav: AudioStreamWAV = bundle["audio"]["audio_overlay"]
	if audio_wav:
		ResourceSaver.save(audio_wav, dir_path + "audio.tres")
		
	var metadata = {
		"world_id": bundle["world_id"],
		"hash": hash_val,
		"content_version": bundle["content_version"],
		"noise_path": dir_path + "noise.png",
		"iris_path": dir_path + "iris.tres",
		"audio_path": dir_path + "audio.tres"
	}
	
	var file = FileAccess.open(dir_path + "bundle.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(metadata, "\t"))
		file.close()
		print("[COMPILER] World cache written immutably for hash: ", hash_val)

static func compile_world(descriptor: Dictionary) -> Dictionary:
	if not validate_descriptor(descriptor):
		return {}
		
	var hash_val = compute_hash(descriptor)
	var det = descriptor.get("determinism", {})
	var expected_version = det.get("content_version", "1.0.0")
	var ident = descriptor.get("identity", {})
	var world_id = ident.get("world_id", "default")
	
	if cache_exists(hash_val, expected_version):
		print("[COMPILER] Immutable cache hit for world hash: ", hash_val)
		return get_bundle(hash_val)
		
	print("[COMPILER] Cache miss. Initiating deterministic build pipeline for hash: ", hash_val)
	var noise = generate_noise(descriptor)
	var mesh = generate_iris_mesh(descriptor)
	var audio = generate_audio(descriptor)
	
	var bundle = pack(world_id, hash_val, noise, mesh, audio, expected_version)
	write_cache(bundle)
	return bundle

static func get_bundle(hash_val: int) -> Dictionary:
	var dir_path = "user://world_cache/" + str(hash_val) + "/"
	var file = FileAccess.open(dir_path + "bundle.json", FileAccess.READ)
	if not file:
		push_error("[COMPILER ERROR] Requested bundle.json missing for hash: " + str(hash_val))
		return {}
		
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		push_error("[COMPILER FATAL] Corrupted bundle.json for hash: " + str(hash_val))
		return {}
	file.close()
	
	var data = json.get_data()
	var noise_path = data.get("noise_path", dir_path + "noise.png")
	var iris_path = data.get("iris_path", dir_path + "iris.tres")
	var audio_path = data.get("audio_path", dir_path + "audio.tres")
	
	var noise_tex = null
	if FileAccess.file_exists(noise_path):
		var img = Image.load_from_file(noise_path)
		if img: noise_tex = ImageTexture.create_from_image(img)
		
	var iris_mesh = null
	if FileAccess.file_exists(iris_path):
		iris_mesh = ResourceLoader.load(iris_path, "ArrayMesh")
		
	var audio_wav = null
	if FileAccess.file_exists(audio_path):
		audio_wav = ResourceLoader.load(audio_path, "AudioStreamWAV")
		
	return {
		"world_id": data.get("world_id", "default"),
		"hash": hash_val,
		"content_version": data.get("content_version", "1.0.0"),
		"textures": {"bg_noise": noise_tex, "bg_noise_path": noise_path},
		"meshes": {"iris_accent": iris_mesh, "iris_accent_path": iris_path},
		"audio": {"audio_overlay": audio_wav, "audio_overlay_path": audio_path}
	}

static func get_or_compile_world(universe_id: String, world_id: String, modifiers: Dictionary = {}) -> Dictionary:
	var seed_val = (universe_id + "_" + world_id).hash()
	var content_version = "1.0.0"
	
	var engine = Engine.get_main_loop()
	if engine and engine.root.has_node("GitHubSyncManager"):
		content_version = engine.root.get_node("GitHubSyncManager").get_active_content_version()
		
	var color_palette = modifiers.get("palette", {
		"primary": Color(0.2, 0.8, 0.8),
		"secondary": Color(0.1, 0.4, 0.4),
		"accent": Color(0.9, 0.1, 0.5)
	})
	
	var descriptor = {
		"schema_version": 1,
		"identity": {
			"universe_id": universe_id,
			"world_id": world_id
		},
		"determinism": {
			"seed": seed_val,
			"content_version": content_version
		},
		"visual_profile": {
			"color_palette": color_palette,
			"fog_density": modifiers.get("fog_density", 0.6),
			"contrast": modifiers.get("contrast", 1.0),
			"motion_profile": modifiers.get("motion_profile", "linear"),
			"noise_profile": {
				"type": modifiers.get("noise_type", "perlin"),
				"scale": modifiers.get("noise_scale", 4.0),
				"intensity": modifiers.get("noise_intensity", 1.0)
			}
		},
		"iris_profile": {
			"base_shape": modifiers.get("iris_shape", "ring"),
			"accent_type": modifiers.get("iris_accent", "prismatic"),
			"complexity": modifiers.get("complexity", 1)
		},
		"audio_profile": {
			"base_freq": modifiers.get("base_freq", 440.0),
			"harmonics": modifiers.get("harmonics", 3),
			"distortion": modifiers.get("distortion", 0.0),
			"spatial_width": modifiers.get("spatial_width", 1.0),
			"sfx_pitch": modifiers.get("sfx_pitch", 1.0)
		},
		"generation_flags": {
			"allow_dynamic_mesh": true,
			"allow_audio_synthesis": true,
			"cache_output": true
		}
	}
	
	return compile_world(descriptor)
