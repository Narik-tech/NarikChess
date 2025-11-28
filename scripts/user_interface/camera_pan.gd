extends Camera2D

const speed = 10
const scrollSpeed = .1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity := Vector2.ZERO
	if Input.is_action_pressed("Down") : velocity += Vector2.DOWN * speed
	if Input.is_action_pressed("Left") : velocity += Vector2.LEFT * speed
	if Input.is_action_pressed("Right") : velocity += Vector2.RIGHT * speed
	if Input.is_action_pressed("Up") : velocity += Vector2.UP * speed
	position += velocity
	
	if Input.is_action_pressed("Scroll Out") : 
		print("zoomind")
		zoom += Vector2.ONE * scrollSpeed
	if Input.is_action_pressed("Scroll In") : zoom -= Vector2.ONE * scrollSpeed
		
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Scroll Out"):
		zoom -= Vector2.ONE * scrollSpeed
	if Input.is_action_pressed("Scroll In"): 
		zoom += Vector2.ONE * scrollSpeed
	if zoom < Vector2.ONE * .1:
		zoom = Vector2.ONE * .1
