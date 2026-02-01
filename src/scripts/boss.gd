extends Area2D


@export var player: CharacterBody2D
@export var hp: float = 1000
@export var float_speed: float = 2.0    # 浮动的速度
@export var float_amplitude: float = 10.0 # 浮动的高度（像素）
var initial_y: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_y = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	if not player.gameover:
		position.y = initial_y + sin(time * float_speed) * float_amplitude


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		var damage_dealt = area.get("damage")
		if damage_dealt == null:
			damage_dealt = 1.0
		hp -= damage_dealt
		area.queue_free()

		if hp <= 0:
			pass

func nonspell1() -> void:
	pass

func spell1() -> void:
	pass

func nonspell2() -> void:
	pass

func spell2() -> void:
	pass

func nonspell3() -> void:
	pass

func spell3() -> void:
	pass

func nonspell4() -> void:
	pass

func spell4() -> void:
	pass

func nonspell5() -> void:
	pass

func spell5() -> void:
	pass

func nonspell6() -> void:
	pass

func spell6() -> void:
	pass

func nonspell7() -> void:
	pass

func spell7() -> void:
	pass

func nonspell8() -> void:
	pass

func spell8() -> void:
	pass

