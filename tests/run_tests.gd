extends SceneTree

func _init() -> void:
	print("==========================================")
	print("        KIEM TIEN TEST RUNNER             ")
	print("==========================================")
	
	var test_files: Array[String] = _find_test_files("res://tests")
	var total_tests: int = 0
	var passed_tests: int = 0
	var failed_tests: int = 0
	var failure_details: Array[String] = []
	
	if test_files.is_empty():
		print("Warning: No test files found in res://tests")
	
	for file_path in test_files:
		print("\n[RUNNING SUITE] %s" % file_path)
		var script = load(file_path)
		if script == null or not (script is GDScript):
			printerr("  Failed to load script: %s" % file_path)
			failed_tests += 1
			failure_details.append("%s: Failed to load script" % file_path)
			continue
			
		var instance = script.new()
		if instance == null:
			printerr("  Failed to instantiate test class: %s" % file_path)
			failed_tests += 1
			failure_details.append("%s: Failed to instantiate script" % file_path)
			continue
		
		# Find test methods
		var methods = instance.get_method_list()
		var test_methods: Array[String] = []
		for m in methods:
			var m_name: String = m["name"]
			if m_name.begins_with("test_") and m_name != "test_base":
				test_methods.append(m_name)
		
		test_methods.sort()
		
		for method_name in test_methods:
			total_tests += 1
			var fail_count_before = 0
			if "failures" in instance:
				fail_count_before = instance.failures.size()
				instance.current_test_name = method_name
			
			instance.call(method_name)
			
			var failed: bool = false
			if "failures" in instance and instance.failures.size() > fail_count_before:
				failed = true
				var new_failures = instance.failures.slice(fail_count_before)
				for f in new_failures:
					failure_details.append("%s::%s" % [file_path.get_file(), f])
			
			if failed:
				failed_tests += 1
				print("  [FAIL] %s" % method_name)
			else:
				passed_tests += 1
				print("  [PASS] %s" % method_name)
				
		if instance is Node:
			instance.queue_free()
	
	print("\n------------------------------------------")
	print("Test Results: %d passed, %d failed (Total: %d)" % [passed_tests, failed_tests, total_tests])
	if failed_tests > 0:
		print("\nFAILURES:")
		for f in failure_details:
			print("  - %s" % f)
		print("==========================================")
		print("RESULT: FAILED")
		print("==========================================")
		quit(1)
	else:
		print("==========================================")
		print("RESULT: ALL TESTS PASSED (SUCCESS)")
		print("==========================================")
		quit(0)

func _find_test_files(dir_path: String) -> Array[String]:
	var result: Array[String] = []
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return result
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.begins_with("test_") and file_name.ends_with(".gd") and file_name != "test_base.gd":
				result.append(dir_path.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	result.sort()
	return result
