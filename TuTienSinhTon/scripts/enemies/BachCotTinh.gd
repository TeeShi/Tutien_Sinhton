# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          BẠCH CỐT TINH                                    ║
# ║                    Boss Enemy - White Bone Spirit                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Bạch Cốt Tinh - Boss đầu tiên                                           │
# │                                                                         │
# │ ĐẶC ĐIỂM:                                                               │
# │   - HP rất cao (100)                                                    │
# │   - Damage cao (20)                                                     │
# │   - Di chuyển chậm nhưng ổn định                                        │
# │   - Khi chết drop nhiều XP và Gold                                      │
# │   - Có thể có skill đặc biệt (sau này)                                  │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseEnemy


# Boss-specific variables
var is_enraged: bool = false  # Boost stats khi HP thấp


func _ready() -> void:
	# Set enemy info
	enemy_id = "bach_cot_tinh"
	enemy_name = "Bạch Cốt Tinh"
	enemy_type = EnemyType.BOSS
	
	# Stats - Boss level
	max_hp = 100
	damage = 20
	move_speed = 40.0  # Chậm nhưng đáng sợ
	xp_value = 50
	gold_value = 10
	attack_cooldown = 1.0
	knockback_resistance = 0.8  # Gần như không bị đẩy
	
	# Call parent
	super._ready()
	
	# Notify boss spawned
	Events.boss_spawned.emit(self)
	print("⚠️ BOSS XUẤT HIỆN: ", enemy_name, "!")


func take_damage(amount: float, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	super.take_damage(amount, knockback_direction)
	
	# Enrage khi HP dưới 30%
	if not is_enraged and current_hp < max_hp * 0.3:
		_enrage()


func _enrage() -> void:
	is_enraged = true
	
	# Boost stats
	move_speed *= 1.5
	damage = int(damage * 1.5)
	attack_cooldown *= 0.7
	
	# Visual feedback (có thể thêm effect sau)
	if sprite:
		sprite.modulate = Color(1, 0.3, 0.3)  # Đỏ lên
	
	print("💀 ", enemy_name, " CUỒNG NỘ!")


func _die() -> void:
	print("🎉 BOSS ", enemy_name, " ĐÃ BỊ TIÊU DIỆT!")
	super._die()
