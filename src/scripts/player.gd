extends CharacterBody2D

@export var heart = 3
@export var move_speed : float = 500
var initial_x: float
var initial_y: float
var _modulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_x = position.x
	initial_y = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("left", "right", "up", "down") * move_speed
	move_and_slide()

func hit() -> void:
	heart -= 1
	set_physics_process(false) 
	_modulate = modulate
	modulate = Color.RED
	await get_tree().create_timer(0.25).timeout
	if heart == 0:
		get_tree().call_deferred("reload_current_scene")
	else:
		position.x = initial_x
		position.y = initial_y
		set_physics_process(true)
		modulate = _modulate
