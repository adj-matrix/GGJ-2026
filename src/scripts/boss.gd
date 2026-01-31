extends Area2D


@export var float_speed: float = 2.0    # 浮动的速度
@export var float_amplitude: float = 10.0 # 浮动的高度（像素）
var initial_y: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_y = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0 
	position.y = initial_y + sin(time * float_speed) * float_amplitude


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit()
