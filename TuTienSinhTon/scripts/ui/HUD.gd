# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              HUD CONTROLLER                               ║
# ║                    Control hiển thị UI trong game                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Control


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var time_label: Label = $TimeLabel
@onready var level_label: Label = $LevelLabel
@onready var kill_count_label: Label = $KillCountLabel


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Connect signals từ Events
	Events.player_health_changed.connect(_on_player_health_changed)
	Events.xp_changed.connect(_on_xp_changed)
	Events.time_updated.connect(_on_time_updated)
	Events.enemy_killed.connect(_on_enemy_killed)
	Events.level_up_started.connect(_on_level_up)
	
	print("HUD initialized!")


# ═══════════════════════════════════════════════════════════════════════════
#                           SIGNAL HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_player_health_changed(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	health_label.text = "HP: %d/%d" % [current, max_hp]


func _on_xp_changed(current_xp: int, xp_needed: int) -> void:
	xp_bar.max_value = xp_needed
	xp_bar.value = current_xp


func _on_time_updated(current_time: float) -> void:
	var minutes = int(current_time) / 60
	var seconds = int(current_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]


func _on_enemy_killed(total_kills: int) -> void:
	kill_count_label.text = "Kills: %d" % total_kills


func _on_level_up(new_level: int) -> void:
	level_label.text = "Level: %d" % new_level
