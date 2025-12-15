# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                            CƯƠNG THI                                       ║
# ║                    Zombie - Slow but Tanky                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Zombie chậm nhưng HP cao hơn - khó tiêu diệt hơn TieuYeuTrung          │
# │ Spawn từ phút 3:00+                                                     │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseEnemy


func _ready() -> void:
	# Set enemy info
	enemy_id = "cuong_thi"
	enemy_name = "Cương Thi"
	enemy_type = EnemyType.SWARM
	
	# Stats - Chậm nhưng tanky
	max_hp = 15
	damage = 10
	move_speed = 40.0 # Slower than TieuYeuTrung
	xp_value = 2
	gold_value = 2
	attack_cooldown = 0.8
	knockback_resistance = 0.3 # Khó đẩy hơn
	
	# Call parent
	super._ready()
