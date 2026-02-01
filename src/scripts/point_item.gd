extends Area2D

@export var score_value: int = 10000
var velocity: Vector2 = Vector2.ZERO
var gravity_speed: float = 800.0
var is_collected: bool = false
var target_player: Node2D = null

func _ready() -> void:
	add_to_group("point_item") 
	body_entered.connect(_on_body_entered) 
	velocity = Vector2(randf_range(-200, 200), randf_range(-300, -500))

func _physics_process(delta: float) -> void:
	if is_collected and target_player:
		# 被磁力吸附模式：直接飞向玩家
		global_position = global_position.move_toward(target_player.global_position, 1200 * delta)
		if global_position.distance_to(target_player.global_position) < 10:
			collect()
	else:
		# 自由落体模式
		velocity.y += gravity_speed * delta
		
		# 空气阻力（让横向速度慢慢变慢，直上直下更好接）
		velocity.x = move_toward(velocity.x, 0, 100 * delta)
		
		position += velocity * delta
		
		# 掉出屏幕销毁
		if position.y > 800:
			queue_free()

# 撞到玩家
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		# 如果还没处于被吸附状态，直接吃掉
		collect()

func collect() -> void:
	# 找到 GameManager 加分
	# 我们稍后会把 GameManager 加入 "game_manager" 组
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("add_score"):
		gm.add_score(score_value)
	
	# TODO: 播放一个“叮”的音效
	queue_free()

func magnet_to(player_node: Node2D) -> void:
	is_collected = true
	target_player = player_node
