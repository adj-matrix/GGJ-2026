extends Node2D


@export var player: CharacterBody2D
@export var score: int = 0
@export var gaze: int = 0
@export var score_label: Label
@export var heart_label: Label
@export var bomb_label: Label
@export var gaze_label: Label
@export var gameover_label: Label
@export var victory_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("game_manager")
	var boss = get_tree().get_first_node_in_group("enemy")
	if boss:
		boss.defeated.connect(show_victory)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_label.text = "Score: " + str(score)
	heart_label.text = "Player: " + "❤️".repeat(max(0, player.heart-1))
	bomb_label.text = "Spell:  " + "🌟".repeat(max(0, player.spell))
	gaze_label.text = "Gaze: " + str(gaze)

func add_score(amount: int) -> void:
	score += amount

func show_gameover() -> void:
	gameover_label.visible = true

func show_victory() -> void:
	await get_tree().create_timer(4).timeout
	# 1. 冻结玩家
	player.is_gameover = true
	# 2. 清除屏幕上所有敌弹（既然赢了，不应该被流弹打死）
	var bullets = get_tree().get_nodes_in_group("enemy_bullet")
	for b in bullets:
		b.queue_free()
	# 3. 显示胜利文字
	if victory_label:
		victory_label.text = "STAGE CLEAR!!\nScore: " + str(score)
		victory_label.visible = true
	# 4. 停止 Boss 战背景音乐，放个胜利音效（如果有）

	# 5. 等待几秒返回主菜单或重启
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://src/scenes/Title.tscn") # 假设你有标题场景
