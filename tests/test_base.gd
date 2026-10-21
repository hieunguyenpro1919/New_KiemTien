class_name TestCase
extends RefCounted

var current_test_name: String = ""
var failures: Array[String] = []

func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		var err_msg = "Expected condition to be true."
		if message != "":
			err_msg += " (" + message + ")"
		_record_failure(err_msg)

func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		var err_msg = "Expected condition to be false."
		if message != "":
			err_msg += " (" + message + ")"
		_record_failure(err_msg)

func assert_not_null(val, message: String = "") -> void:
	if val == null:
		var err_msg = "Expected value not to be null."
		if message != "":
			err_msg += " (" + message + ")"
		_record_failure(err_msg)


func assert_eq(actual, expected, message: String = "") -> void:
	if actual != expected:
		var err_msg = "Assertion failed: expected '%s', got '%s'." % [str(expected), str(actual)]
		if message != "":
			err_msg += " (" + message + ")"
		_record_failure(err_msg)

func assert_almost_eq(actual: float, expected: float, tolerance: float = 0.001, message: String = "") -> void:
	if abs(actual - expected) > tolerance:
		var err_msg = "Assertion failed: expected ~'%f', got '%f' (tol %f)." % [expected, actual, tolerance]
		if message != "":
			err_msg += " (" + message + ")"
		_record_failure(err_msg)

func _record_failure(error_msg: String) -> void:
	failures.append("[%s] %s" % [current_test_name, error_msg])
