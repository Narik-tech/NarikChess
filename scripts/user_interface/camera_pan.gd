## Summary: Camera controller that pans and zooms based on input actions.
extends Camera2D

const speed = 1000
const base_zoom = Vector2(1, 1)
var calc_zoom: Vector2 = Vector2(1, 1)

@export var scroll_speed := 0.3
@export var min_zoom := base_zoom * 0.1
@export var max_zoom := base_zoom * 6.0

func _process(delta: float) -> void:
	var velocity := Vector2.ZERO

	if Input.is_action_pressed("Down"):
		velocity += Vector2.DOWN * speed
	if Input.is_action_pressed("Left"):
		velocity += Vector2.LEFT * speed
	if Input.is_action_pressed("Right"):
		velocity += Vector2.RIGHT * speed
	if Input.is_action_pressed("Up"):
		velocity += Vector2.UP * speed

	if velocity != Vector2.ZERO:
		position += velocity * (1/calc_zoom.x) * delta
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Scroll Out"):
		calc_zoom -= base_zoom * scroll_speed
	elif event.is_action_pressed("Scroll In"):
		calc_zoom += base_zoom * scroll_speed

	calc_zoom = calc_zoom.clamp(min_zoom, max_zoom)
	zoom = Vector2(calc_zoom.x, calc_zoom.y)
