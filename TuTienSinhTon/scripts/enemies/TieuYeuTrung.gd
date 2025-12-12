# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          TIỂU YÊU TRÙNG                                   ║
# ║                    Basic Swarm Enemy                                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Enemy đơn giản nhất - spawn NHIỀU, chết NHANH, cho XP                   │
# │ Tương đương với "Bat" trong Vampire Survivors                           │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseEnemy


func _ready() -> void:
	# Thêm vào group "enemies" để weapon có thể tìm
	add_to_group("enemies")
	
	# Set enemy info
	enemy_id = "tieu_yeu_trung"
	enemy_name = "Tiểu Yêu Trùng"
	enemy_type = EnemyType.SWARM
	
	# Stats - Yếu nhưng đông
	max_hp = 5
	damage = 5
	move_speed = 60.0
	xp_value = 1
	gold_value = 0
	attack_cooldown = 0.5
	knockback_resistance = 0.0  # Bị đẩy dễ dàng
	
	# Call parent
	super._ready()
