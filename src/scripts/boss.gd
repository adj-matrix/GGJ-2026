extends Area2D

@export var player: CharacterBody2D
@export var enemy_bullet_scene: PackedScene = preload("res://bullet_enemy.tscn")
@export var point_item_scene: PackedScene = preload("res://point_item.tscn") 
@export var max_hp: float = 1000.0
var hp: float = 1000.0

signal defeated

var initial_y: float
var time_counter: float = 0.0

enum State { NONSPELL_1, SPELL_1, NONSPELL_2, SPELL_2, FINISH }
var current_state = State.NONSPELL_1
# --- 新增：记录上一次的状态，用于检测状态变化 ---
var last_state = State.NONSPELL_1 

var fire_timer: float = 0.0
var fire_interval: float = 0.1

func _ready() -> void:
	initial_y = position.y
	hp = max_hp
	add_to_group("enemy")

func _process(delta: float) -> void:
	time_counter += delta
	if player and not player.is_gameover:
		position.y = initial_y + sin(time_counter * 2.0) * 10.0
	
	check_phase()
	
	fire_timer -= delta
	if fire_timer <= 0 and player and not player.is_gameover:
		attack_pattern()

func check_phase() -> void:
	var hp_percent = hp / max_hp
	
	# 临时变量存储新状态
	var new_state = current_state
	
	if hp_percent > 0.8:
		new_state = State.NONSPELL_1
		fire_interval = 0.5
	elif hp_percent > 0.6:
		new_state = State.SPELL_1
		fire_interval = 0.1
	elif hp_percent > 0.4:
		new_state = State.NONSPELL_2
		fire_interval = 0.3
	elif hp_percent > 0.0:
		new_state = State.SPELL_2
		fire_interval = 0.08
	else:
		new_state = State.FINISH
		if current_state != State.FINISH: # 防止重复触发死亡逻辑
			spawn_score_items(50) # Boss 死的时候爆一大堆！
			set_process(false)
			defeated.emit()
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 1.0)
			tween.parallel().tween_property(self, "scale", Vector2(2, 2), 1.0)
			await tween.finished
			queue_free()
			return # 结束函数

	# --- 核心：检测状态是否改变（击破判定）---
	if new_state != current_state:
		# 状态变了，说明刚刚打完了一个阶段
		# 消除当前屏幕上的敌弹（奖励）
		clear_enemy_bullets()
		# 爆出分数道具 (比如爆 20 个)
		spawn_score_items(20)
		
		# 更新当前状态
		current_state = new_state
		# 重置一下开火计时器，给玩家一点喘息时间
		fire_timer = 1.0

func attack_pattern() -> void:
	match current_state:
		State.NONSPELL_1:
			shoot_aimed(500)
			fire_timer = 0.5
		State.SPELL_1:
			shoot_circle(12, 300, time_counter * 100)
			fire_timer = 0.15
		State.NONSPELL_2:
			shoot_aimed(600)
			shoot_circle(4, 400, 0)
			fire_timer = 0.3
		State.SPELL_2:
			shoot_circle(16, 400, time_counter * 200)
			shoot_circle(16, 350, -time_counter * 200)
			fire_timer = 0.1

func shoot_circle(count: int, speed: float, angle_offset: float) -> void:
	for i in range(count):
		var angle = i * (360.0 / count) + angle_offset
		var bullet = enemy_bullet_scene.instantiate()
		bullet.global_position = global_position
		var rad = deg_to_rad(angle)
		bullet.direction = Vector2(cos(rad), sin(rad))
		bullet.speed = speed
		get_tree().current_scene.add_child(bullet)

func shoot_aimed(speed: float) -> void:
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.speed = speed
	bullet.look_at(player.global_position)
	get_tree().current_scene.add_child(bullet)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		var damage_dealt = area.get("damage")
		if damage_dealt == null: damage_dealt = 1.0
		hp -= damage_dealt
		area.queue_free()

# --- 新增：爆道具逻辑 ---
func spawn_score_items(count: int) -> void:
	if not point_item_scene: return
	
	for i in range(count):
		var item = point_item_scene.instantiate()
		item.global_position = global_position
		# 稍微随机一点位置，别全叠在一起
		item.global_position += Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_tree().current_scene.call_deferred("add_child", item)

# --- 新增：击破时清屏逻辑 ---
func clear_enemy_bullets() -> void:
	var bullets = get_tree().get_nodes_in_group("enemy_bullet")
	for b in bullets:
		# 可以做个特效，或者变成小加分道具
		b.queue_free()
