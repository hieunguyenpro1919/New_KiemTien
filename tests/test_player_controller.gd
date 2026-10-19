extends "res://tests/test_base.gd"

const PlayerController = preload("res://scripts/actors/player_controller.gd")

func test_player_initial_state() -> void:
	var player = PlayerController.new()
	assert_eq(player.current_state, PlayerController.State.IDLE, "Player should start in IDLE state")
	assert_eq(player.move_speed, 220.0, "Move speed must default to 220 px/s per SPEC 5.1")
	assert_eq(player.facing_direction, Vector2.DOWN, "Initial facing direction should be DOWN")
	player.free()

func test_player_cardinal_movement() -> void:
	var player = PlayerController.new()
	
	# Test Right
	player.update_movement_and_state(Vector2.RIGHT)
	assert_eq(player.current_state, PlayerController.State.MOVE, "State should be MOVE")
	assert_almost_eq(player.velocity.x, 220.0, 0.001, "Right speed should be 220")
	assert_almost_eq(player.velocity.y, 0.0, 0.001, "Y velocity should be 0")
	assert_eq(player.facing_direction, Vector2.RIGHT, "Facing direction should be RIGHT")
	
	# Test Up
	player.update_movement_and_state(Vector2.UP)
	assert_eq(player.current_state, PlayerController.State.MOVE, "State should be MOVE")
	assert_almost_eq(player.velocity.y, -220.0, 0.001, "Up speed should be -220")
	assert_eq(player.facing_direction, Vector2.UP, "Facing direction should be UP")
	
	player.free()

func test_player_diagonal_normalization() -> void:
	var player = PlayerController.new()
	
	# Unnormalized diagonal input
	var raw_diagonal = Vector2(1.0, 1.0)
	var normalized_diagonal = raw_diagonal.normalized()
	
	player.update_movement_and_state(normalized_diagonal)
	assert_eq(player.current_state, PlayerController.State.MOVE, "State should be MOVE")
	assert_almost_eq(player.velocity.length(), 220.0, 0.001, "Diagonal speed must be normalized to 220.0 px/s")
	assert_almost_eq(player.velocity.x, 220.0 * 0.70710678, 0.01, "X component should be ~155.56")
	assert_almost_eq(player.velocity.y, 220.0 * 0.70710678, 0.01, "Y component should be ~155.56")
	
	player.free()

func test_player_stop_and_preserve_facing() -> void:
	var player = PlayerController.new()
	
	# Move Left
	player.update_movement_and_state(Vector2.LEFT)
	assert_eq(player.facing_direction, Vector2.LEFT, "Facing should be LEFT")
	
	# Stop
	player.update_movement_and_state(Vector2.ZERO)
	assert_eq(player.current_state, PlayerController.State.IDLE, "State should return to IDLE")
	assert_eq(player.velocity, Vector2.ZERO, "Velocity should be ZERO when stopped")
	assert_eq(player.facing_direction, Vector2.LEFT, "Facing direction must be preserved after stopping")
	
	player.free()
