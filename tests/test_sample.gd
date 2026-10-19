extends "res://tests/test_base.gd"

func test_sample_math() -> void:
	assert_eq(1 + 1, 2, "Basic arithmetic check")
	assert_true(100 > 50, "Comparison check")

func test_vector_normalization() -> void:
	var v = Vector2(1, 1).normalized()
	assert_almost_eq(v.length(), 1.0, 0.0001, "Diagonal vector length should normalize to 1.0")
