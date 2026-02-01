extends Node

@onready var bgm_normal_stream = preload("res://assets/sounds/TFM-006b_16.mp3")
@onready var bgm_final_stream = preload("res://assets/sounds/TFM-006b_13.mp3")
@onready var sfx_pichu = preload("res://assets/sounds/pichu.wav")
@onready var sfx_boss_shot = preload("res://assets/sounds/tan00.wav")
@onready var sfx_hit = preload("res://assets/sounds/damage00.wav")
@onready var sfx_item = preload("res://assets/sounds/item00.wav")
@onready var sfx_bomb = preload("res://assets/sounds/nep00.wav")

# 专门用来放 BGM 的播放器
var bgm_player: AudioStreamPlayer

func _ready() -> void:
	# 初始化 BGM 播放器
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Master" # 或者 "Music" 如果你设置了的话

func play_bgm_normal():
	if bgm_player.stream != bgm_normal_stream:
		bgm_player.stream = bgm_normal_stream
		bgm_player.play()

func play_bgm_final():
	if bgm_player.stream != bgm_final_stream:
		bgm_player.stream = bgm_final_stream
		bgm_player.play()

func stop_bgm():
	bgm_player.stop()

# --- SFX 部分保持不变 ---
func play_sfx(stream: AudioStream, volume = 0.0):
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	asp.volume_db = volume
	add_child(asp)
	asp.play()
	asp.finished.connect(asp.queue_free)

func play_pichu(): play_sfx(sfx_pichu)
func play_boss_shot(): play_sfx(sfx_boss_shot, -15.0)
func play_hit(): play_sfx(sfx_hit, -5.0)
func play_item(): play_sfx(sfx_item, -10.0) # 道具多，声音调小点
func play_bomb(): play_sfx(sfx_bomb)
