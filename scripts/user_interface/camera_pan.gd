## Summary: Camera controller that pans and zooms based on input actions.
extends Camera2D

const SPEED = 1000
const scrollSpeed = .1
@export var scroll_speed := 0.3
@export var min_zoom := Vector2.ONE * 0.1
@export var max_zoom := Vector2.ONE * 6.0

func _process(delta: float) -> void:
	var velocity := Vector2.ZERO

	if Input.is_action_pressed("Down"):
		velocity += Vector2.DOWN * SPEED
	if Input.is_action_pressed("Left"):
		velocity += Vector2.LEFT * SPEED
	if Input.is_action_pressed("Right"):
		velocity += Vector2.RIGHT * SPEED
	if Input.is_action_pressed("Up"):
		velocity += Vector2.UP * SPEED

	if velocity != Vector2.ZERO:
		position += velocity * (1/zoom.x) * delta
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Scroll Out"):
		zoom -= Vector2.ONE * scroll_speed
	elif event.is_action_pressed("Scroll In"):
		zoom += Vector2.ONE * scroll_speed

	zoom = zoom.clamp(min_zoom, max_zoom)
