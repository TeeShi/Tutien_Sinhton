# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          LIGHTNING STRIKE EFFECT                          ║
# ║                    Hiệu ứng sét đánh - Visual only                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Node2D


# ═══════════════════════════════════════════════════════════════════════════
#                              PROPERTIES
# ═══════════════════════════════════════════════════════════════════════════

var duration: float = 0.3
var lifetime: float = 0.0


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var sprite: Sprite2D = $Sprite2D


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func setup(dur: float) -> void:
	duration = dur


func _ready() -> void:
	# Flash effect
	if sprite:
		sprite.modulate = Color(1, 1, 0.8, 1)  # Vàng sáng


# ═══════════════════════════════════════════════════════════════════════════
#                              PROCESS
# ═══════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	lifetime += delta
	
	# Fade out
	var progress = lifetime / duration
	if sprite:
		sprite.modulate.a = 1.0 - progress
	
	# Xóa khi hết thời gian
	if lifetime >= duration:
		queue_free()
