# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              YÊU LANG                                     ║
# ║                    Elite Enemy - Demon Wolf                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Yêu Lang - Sói ma mạnh hơn, ít hơn                                      │
# │ Tương đương với "SmallMonster" trong Vampire Survivors                  │
# │                                                                         │
# │ ĐẶC ĐIỂM:                                                               │
# │   - HP cao hơn TiểuYêuTrùng x3                                          │
# │   - Damage cao hơn x2                                                   │
# │   - Di chuyển nhanh hơn x1.5                                            │
# │   - XP drop nhiều hơn x5                                                │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseEnemy


func _ready() -> void:
	# Set enemy info
	enemy_id = "yeu_lang"
	enemy_name = "Yêu Lang"
	enemy_type = EnemyType.ELITE
	
	# Stats - Mạnh hơn nhưng ít hơn
	max_hp = 25
	damage = 10
	move_speed = 80.0
	xp_value = 5
	gold_value = 1
	attack_cooldown = 0.8
	knockback_resistance = 0.3  # Khó đẩy hơn
	
	# Call parent
	super._ready()
