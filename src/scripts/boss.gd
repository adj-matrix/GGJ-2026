extends Area2D

@export var player: CharacterBody2D
@export var enemy_bullet_scene: PackedScene = preload("res://bullet_enemy.tscn")
@export var max_hp: float = 1000.0
var hp: float = 1000.0

# 浮动参数
var initial_y: float
var time_counter: float = 0.0

# 战斗状态机
enum State { NONSPELL_1, SPELL_1, NONSPELL_2, SPELL_2, FINISH }
var current_state = State.NONSPELL_1
var fire_timer: float = 0.0
var fire_interval: float = 0.1 # 射击间隔（秒）

func _ready() -> void:
	initial_y = position.y
	hp = max_hp
	add_to_group("enemy") # 确保你的追踪子弹能找到它

func _process(delta: float) -> void:
	# 1. 浮动逻辑
	time_counter += delta
	if player and not player.is_gameover:
		position.y = initial_y + sin(time_counter * 2.0) * 10.0
	
	# 2. 状态管理 (根据血量切阶段)
	check_phase()
	
	# 3. 攻击逻辑
	fire_timer -= delta
	if fire_timer <= 0 and player and not player.is_gameover:
		attack_pattern()

# --- 核心：自动切阶段 ---
func check_phase() -> void:
	var hp_percent = hp / max_hp
	
	# 简单的硬编码阶段切换，你可以根据需要调整阈值
	if hp_percent > 0.8:
		current_state = State.NONSPELL_1
		fire_interval = 0.5 # 慢点射
	elif hp_percent > 0.6:
		current_state = State.SPELL_1
		fire_interval = 0.1 # 快射
	elif hp_percent > 0.4:
		current_state = State.NONSPELL_2
		fire_interval = 0.3
	elif hp_percent > 0.0:
		current_state = State.SPELL_2
		fire_interval = 0.08
	else:
		current_state = State.FINISH
		# Boss 死亡逻辑，比如播放动画然后 queue_free
		queue_free()

# --- 核心：攻击模式 ---
func attack_pattern() -> void:
	match current_state:
		State.NONSPELL_1:
			# 模式1：简单的自机狙（向玩家发射）
			shoot_aimed(500)
			fire_timer = 0.5
			
		State.SPELL_1:
			# 模式2：华丽的旋转圆圈弹
			# 利用 time_counter 作为一个不断旋转的角度
			shoot_circle(12, 300, time_counter * 100) 
			fire_timer = 0.15
			
		State.NONSPELL_2:
			# 模式3：快速散弹
			shoot_aimed(600)
			shoot_circle(4, 400, 0)
			fire_timer = 0.3
			
		State.SPELL_2:
			# 模式4：发狂模式！双螺旋
			shoot_circle(16, 400, time_counter * 200)
			shoot_circle(16, 350, -time_counter * 200)
			fire_timer = 0.1

# === 工具函数：发射一圈子弹 ===
# count: 发多少个, speed: 速度, angle_offset: 整体旋转角度
func shoot_circle(count: int, speed: float, angle_offset: float) -> void:
	for i in range(count):
		var angle = i * (360.0 / count) + angle_offset
		var bullet = enemy_bullet_scene.instantiate()
		bullet.global_position = global_position
		# 极坐标转换：角度转向量
		var rad = deg_to_rad(angle)
		bullet.direction = Vector2(cos(rad), sin(rad))
		bullet.speed = speed
		get_tree().current_scene.add_child(bullet)

# === 工具函数：发射自机狙 ===
func shoot_aimed(speed: float) -> void:
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position
	# 计算指向玩家的方向
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.speed = speed
	bullet.look_at(player.global_position) # 让子弹朝向玩家
	get_tree().current_scene.add_child(bullet)

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
