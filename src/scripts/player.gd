extends CharacterBody2D

@export var heart: int = 3
@export var spell: int = 3
@export var move_speed: float = 500
@export var move_speed_slow: float = 200
@export var fire_speed: float = 0.05
@export var bomb_damage: float = 100.0
@export var bomb_duration: float = 2.0
@export var collection_line_y: float = 200
@export var bullet_basic_scene: PackedScene = preload("res://bullet_basic.tscn")
@export var bullet_fast_scene: PackedScene = preload("res://bullet_fast.tscn")
@export var bullet_slow_scene: PackedScene = preload("res://bullet_slow.tscn")

var initial_position: Vector2
var is_slow: bool = false
var is_invincible: bool = false
var is_gameover: bool = false
var can_fire: bool = true
var deathbomb_timer: float = 0.0
var deathbomb_window: float = 0.2 # 决死时间窗口（秒）
var is_dying: bool = false

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
	if not is_gameover:
		move_and_slide()
		check_point_collection()

	if is_dying:
		deathbomb_timer -= _delta
		if deathbomb_timer <= 0:
			actually_die() # 时间到了没按 B，真死

	if Input.is_action_pressed("fire") and not is_gameover:
		fire()
	if Input.is_action_just_pressed("bomb") and not is_gameover:
		if is_dying and spell > 0:
			is_dying = false
			AudioManager.play_hit()
			bomb()
		elif not is_dying:
			bomb()

func hit() -> void:
	if is_invincible or is_dying:
		return

	if spell > 0:
		is_dying = true
		deathbomb_timer = deathbomb_window
	else:
		actually_die()


func actually_die() -> void:
	is_dying = false

	heart -= 1
	spell = 3
	is_invincible = true
	AudioManager.play_pichu()

	if heart <= 0:
		gameover()
	else:
		position = initial_position
		modulate = default_color
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

	# 启动冷却计时器
	await get_tree().create_timer(fire_speed).timeout
	can_fire = true

func bomb() -> void:
	if spell > 0 and not is_gameover:
		spell -= 1
		# 1. 开启无敌
		is_invincible = true
		modulate.a = 0.5 # 变半透明提示无敌
		# 2. 全屏消弹 (清除所有 enemy_bullet 组的节点)
		var bullets = get_tree().get_nodes_in_group("enemy_bullet")
		for b in bullets:
			# 可以在这里生成一个简单的粒子特效或者加分道具
			b.queue_free()
		# 3. 对 Boss 造成伤害
		# 找到所有 enemy 组的节点 (也就是 Boss)
		var enemies = get_tree().get_nodes_in_group("enemy")
		for e in enemies:
			if "hp" in e: # 检查是否有 hp 属性
				e.hp -= bomb_damage
		# 4. 视觉特效：屏幕闪白 (梦想封印！)
		flash_screen_effect()
		# 5. 播放一个巨大的爆炸声
		AudioManager.play_bomb()
		# 6. 处理无敌时间结束
		# 创建一个计时器，等时间到了再恢复
		await get_tree().create_timer(bomb_duration).timeout
		# 只有在没有 Gameover 的情况下才恢复状态
		if not is_gameover:
			is_invincible = false
			modulate.a = 1.0

func gameover() -> void:
	if not is_gameover:
		is_gameover = true

		get_tree().current_scene.show_gameover()
		await get_tree().create_timer(3).timeout
		get_tree().call_deferred("reload_current_scene")

func flash_screen_effect() -> void:
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT) # 铺满全屏
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE # 不挡鼠标
	# 加到 UI 层或者当前场景最上面
	get_tree().current_scene.add_child(flash)
	# 使用 Tween (补间动画) 让它从白色迅速淡出
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.5) # 0.5秒内透明度变0
	tween.tween_callback(flash.queue_free) # 动画结束后删除节点

func check_point_collection() -> void:
	# 如果 Y 坐标小于设定值 (说明在屏幕上方)
	if position.y < collection_line_y:
		# 获取所有属于 "point_item" 组的节点
		var items = get_tree().get_nodes_in_group("point_item")
		for item in items:
			# 调用道具身上的 magnet_to 方法
			# 加上判断防止重复调用 (虽然 point_item 那边覆盖也没事)
			if item.has_method("magnet_to") and not item.is_collected:
				item.magnet_to(self)
