extends CharacterBody2D

@export var heart: int = 3
@export var move_speed: float = 500
@export var move_speed_slow: float = 200
@export var fire_speed: float = 0.05
@export var bullet_basic_scene: PackedScene = preload("res://bullet_basic.tscn")
@export var bullet_fast_scene: PackedScene = preload("res://bullet_fast.tscn")
@export var bullet_slow_scene: PackedScene = preload("res://bullet_slow.tscn")

var initial_position: Vector2
var is_slow: bool = false
var is_invincible: bool = false
var can_fire: bool = true

@onready var sprite = $Sprite2D
@onready var default_color = modulate

func _ready() -> void:
	initial_position = position

func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var current_speed = move_speed
	if Input.is_action_pressed("slow"):
		current_speed = move_speed_slow
		is_slow = true
	else:
		is_slow = false
	velocity = input_dir * current_speed
	move_and_slide()

	if Input.is_action_pressed("fire"):
		fire()
	if Input.is_action_just_pressed("bomb"):
		bomb()

func hit() -> void:
	if is_invincible:
		return

	heart -= 1
	is_invincible = true

	# 播放中弹反馈 TODO: Sound

	if heart <= 0:
		await get_tree().create_timer(0.25).timeout
		get_tree().call_deferred("reload_current_scene")
	else:
		position = initial_position
		modulate = default_color
		# 触发闪烁无敌逻辑
		blink_invincibility()

func blink_invincibility() -> void:
	for i in range(10): # 闪烁10次
		modulate.a = 0.2 if modulate.a == 1.0 else 1.0
		await get_tree().create_timer(0.1).timeout

	modulate.a = 1.0
	is_invincible = false

func fire() -> void:
	if not can_fire: return # 冷却中，直接返回
	can_fire = false # 锁定射击

	var b_left = bullet_basic_scene.instantiate()
	var b_right = bullet_basic_scene.instantiate()
	b_left.global_position = global_position + Vector2(-10, -20)
	b_right.global_position = global_position + Vector2(10, -20)
	get_tree().current_scene.add_child(b_left)
	get_tree().current_scene.add_child(b_right)
	if is_slow:
		var b_slow_left = bullet_slow_scene.instantiate()
		var b_slow_right = bullet_slow_scene.instantiate()
		b_slow_left.global_position = global_position + Vector2(-20, -20)
		b_slow_right.global_position = global_position + Vector2(20, -20)
		get_tree().current_scene.add_child(b_slow_left)
		get_tree().current_scene.add_child(b_slow_right)
	else:
		var b_fast_left = bullet_fast_scene.instantiate()
		var b_fast_right = bullet_fast_scene.instantiate()
		b_fast_left.global_position = global_position + Vector2(-20, -20)
		b_fast_right.global_position = global_position + Vector2(20, -20)

		b_fast_left.velocity = Vector2(-0.5, -1).normalized() * b_fast_left.speed
		b_fast_right.velocity = Vector2(0.5, -1).normalized() * b_fast_right.speed

		get_tree().current_scene.add_child(b_fast_left)
		get_tree().current_scene.add_child(b_fast_right)

	# 播放射击音效 TODO: Sound
	# 启动冷却计时器
	await get_tree().create_timer(fire_speed).timeout
	can_fire = true

func bomb() -> void:
	# 这里写释放大招的逻辑
	pass
