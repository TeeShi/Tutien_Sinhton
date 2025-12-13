# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          GAME OVER SCREEN                                 ║
# ║                    Hiển thị khi player chết                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends CanvasLayer


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var stats_container: VBoxContainer = $Panel/VBoxContainer/StatsContainer
@onready var time_label: Label = $Panel/VBoxContainer/StatsContainer/TimeLabel
@onready var kills_label: Label = $Panel/VBoxContainer/StatsContainer/KillsLabel
@onready var level_label: Label = $Panel/VBoxContainer/StatsContainer/LevelLabel
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Ẩn ban đầu
	visible = false
	
	# Connect signals
	Events.player_died.connect(_on_player_died)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


# ═══════════════════════════════════════════════════════════════════════════
#                           SIGNAL HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_player_died() -> void:
	# Hiển thị Game Over
	visible = true
	
	# Cập nhật stats
	_update_stats()
	
	# Pause game
	get_tree().paused = true


func _update_stats() -> void:
	# Lấy stats từ GameManager
	var time_str = GameManager.get_time_string()
	var kills = GameManager.enemies_killed
	var level = GameManager.current_level
	
	time_label.text = "Thời gian: %s" % time_str
	kills_label.text = "Yêu Ma đã diệt: %d" % kills
	level_label.text = "Cảnh Giới: Level %d" % level


func _on_restart_pressed() -> void:
	# Unpause
	get_tree().paused = false
	
	# Reload scene
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	# Thoát game (hoặc về menu)
	get_tree().quit()
