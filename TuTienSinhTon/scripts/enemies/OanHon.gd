# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                            OAN HỒN                                        ║
# ║                    Ghost - Fast but Fragile                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Ghost nhanh nhưng HP thấp - nguy hiểm vì khó tránh                     │
# │ Spawn từ phút 5:00+                                                     │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseEnemy


func _ready() -> void:
	# Set enemy info
	enemy_id = "oan_hon"
	enemy_name = "Oan Hồn"
	enemy_type = EnemyType.SWARM
	
	# Stats - Fast but fragile
	max_hp = 10
	damage = 12
	move_speed = 80.0 # Faster than other swarms
	xp_value = 2
	gold_value = 2
	attack_cooldown = 0.4 # Attacks faster too
	knockback_resistance = 0.0 # Easy to push
	
	# Call parent
	super._ready()


# Override để thêm hiệu ứng mờ dần (ghost effect)
func _process(_delta: float) -> void:
	if sprite:
		# Subtle pulsing transparency
		sprite.modulate.a = 0.6 + sin(Time.get_ticks_msec() * 0.005) * 0.2
