extends Node2D


@export var player: CharacterBody2D
@export var score: int = 0
@export var gaze: int = 0
@export var score_label: Label
@export var heart_label: Label
@export var bomb_label: Label
@export var gaze_label: Label
@export var gameover_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_label.text = "Score: " + str(score)
	heart_label.text = "Player: " + "❤️".repeat(player.heart-1)
	bomb_label.text = "Spell:  " + "🌟".repeat(player.spell)
	gaze_label.text = "Gaze: " + str(gaze)

func show_gameover() -> void:
	gameover_label.visible = true
