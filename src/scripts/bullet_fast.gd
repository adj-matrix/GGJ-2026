extends Area2D

@export var speed: float = 800
@export var damage: float = 1.0
@export var steer_force: float = 4   # 转向能力（越大拐弯越急，越小拐弯越慢）
var velocity: Vector2 = Vector2.ZERO
var target: Node2D = null

func _ready() -> void:
	# 初始速度：稍微向两边散开一点，这样追踪时的弧线更好看（模仿灵梦的效果）
	# 如果想直接向前，就改成 Vector2.UP * speed
	# 这里我们假设子弹是左右发射的，稍微给一点横向的初速度
	# 比如根据子弹在主角左边还是右边来决定初始方向（这一步通常在Player里传参更好，这里简化处理）
	velocity = Vector2.UP * speed
	
	var bosses = get_tree().get_nodes_in_group("enemy")
	if bosses.size() > 0:
		target = bosses[0]

func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		# 1. 计算指向目标的方向向量
		var direction_to_target = (target.global_position - global_position).normalized()
		
		# 2. 计算理想速度（全速冲向目标）
		var desired_velocity = direction_to_target * speed
		
		# 3. 转向逻辑：让当前速度平滑地过渡到理想速度
		# move_toward 就像是把方向盘慢慢打过去
		# steer_force * delta * speed 这个乘积决定了转向的力度
		velocity = velocity.move_toward(desired_velocity, steer_force * speed * delta)
	
	# 保持速度恒定（避免子弹在拐弯时减速）
	velocity = velocity.normalized() * speed
	
	# 应用移动
	position += velocity * delta
	
	# 让子弹的图片朝向它的飞行方向（视觉效果）
	rotation = velocity.angle() + PI / 2
	
	var boundary = Rect2(100, 25, 560, 625) 
	if not boundary.has_point(global_position):
		queue_free()
