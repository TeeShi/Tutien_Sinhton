# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                      UPGRADE NOTIFICATION                                 ║
# ║              Hiển thị skill đã chọn (auto hoặc manual)                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends CanvasLayer


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var panel: Panel = $Panel
@onready var skill_label: Label = $Panel/VBoxContainer/SkillLabel
@onready var desc_label: Label = $Panel/VBoxContainer/DescLabel
@onready var timer: Timer = $Timer


# ═══════════════════════════════════════════════════════════════════════════
#                              SETTINGS
# ═══════════════════════════════════════════════════════════════════════════

const DISPLAY_DURATION: float = 2.0  # Hiển thị trong 2 giây


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Ẩn ban đầu
	visible = false
	
	# Connect timer
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true


# ═══════════════════════════════════════════════════════════════════════════
#                           PUBLIC METHODS
# ═══════════════════════════════════════════════════════════════════════════

## Hiển thị notification với skill đã chọn
func show_upgrade(skill_name: String, skill_description: String, is_auto: bool = false) -> void:
	# Cập nhật text
	var prefix = "[TỰ ĐỘNG] " if is_auto else ""
	skill_label.text = prefix + skill_name
	desc_label.text = skill_description
	
	# Hiển thị
	visible = true
	
	# Bắt đầu timer
	timer.start(DISPLAY_DURATION)


func _on_timer_timeout() -> void:
	# Ẩn sau khi hết thời gian
	visible = false
