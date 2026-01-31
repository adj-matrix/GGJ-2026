extends Area2D


@export var speed : float = 800
@export var damage: float = 1.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.y -= speed * delta

	var boundary = Rect2(100, 25, 560, 625) 
	if not boundary.has_point(global_position):
		queue_free()
