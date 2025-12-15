# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    DAMAGE NUMBER SPAWNER                                  ║
# ║              Spawn damage numbers khi có show_damage_number signal        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Node


# ═══════════════════════════════════════════════════════════════════════════
#                              SCENE REFERENCE
# ═══════════════════════════════════════════════════════════════════════════

const DAMAGE_NUMBER_SCENE = preload("res://scenes/ui/DamageNumber.tscn")


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Connect signal từ Events
	Events.show_damage_number.connect(_on_show_damage_number)
	print("DamageNumberSpawner ready!")


# ═══════════════════════════════════════════════════════════════════════════
#                           SIGNAL HANDLER
# ═══════════════════════════════════════════════════════════════════════════

func _on_show_damage_number(damage: int, position: Vector2, is_crit: bool) -> void:
	var dmg_number = DAMAGE_NUMBER_SCENE.instantiate()
	dmg_number.global_position = position
	
	# Add to scene tree
	get_tree().current_scene.add_child(dmg_number)
	
	# Setup sau khi add (để _ready chạy trước)
	dmg_number.call_deferred("setup", damage, is_crit, false)
