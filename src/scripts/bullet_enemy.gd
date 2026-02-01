extends Area2D


@export var speed : float = 300
@export var damage: int = 1
var direction: Vector2 = Vector2.DOWN


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	var boundary = Rect2(100, 25, 560, 625) 
	if not boundary.has_point(global_position):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit()
		queue_free()
