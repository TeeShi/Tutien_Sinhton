# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              HỎA CẦU                                      ║
# ║                    Fireball - Quả cầu lửa nổ tung                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ MÔ TẢ:                                                                  │
# │ Bắn quả cầu lửa về phía enemy gần nhất                                  │
# │ Khi chạm enemy hoặc hết thời gian → NỔ gây AoE damage                   │
# │                                                                         │
# │ TƯƠNG TỰ: Fire Wand trong Vampire Survivors                             │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseWeapon


# ═══════════════════════════════════════════════════════════════════════════
#                              CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════

const PROJECTILE_SCENE = preload("res://scenes/projectiles/Fireball.tscn")


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Weapon info
	weapon_id = "hoa_cau"
	weapon_name = "Hỏa Cầu"
	description = "Bắn quả cầu lửa nổ tung gây sát thương diện rộng"
	
	# Base stats
	base_damage = 15.0       # Damage cao hơn PhiKiem
	base_cooldown = 2.5      # Cooldown dài hơn
	base_speed = 250.0       # Tốc độ bay
	base_amount = 1          # Số quả cầu mỗi lần
	base_pierce = 0          # Không xuyên, nổ khi chạm
	base_duration = 3.0      # Thời gian sống
	base_area = 80.0         # Bán kính nổ
	
	super._ready()


# ═══════════════════════════════════════════════════════════════════════════
#                              ATTACK
# ═══════════════════════════════════════════════════════════════════════════

func _attack() -> void:
	if not player:
		return
	
	# Tìm enemy gần nhất
	var target = _find_nearest_enemy()
	if not target:
		return
	
	# Spawn fireballs
	for i in range(current_amount):
		_spawn_fireball(target)


func _spawn_fireball(target: Node2D) -> void:
	var fireball = PROJECTILE_SCENE.instantiate()
	
	# Vị trí spawn từ player
	fireball.global_position = player.global_position
	
	# Hướng về target
	var direction = (target.global_position - player.global_position).normalized()
	
	# Setup fireball
	fireball.setup(
		direction,
		current_damage,
		current_speed,
		current_duration,
		current_area
	)
	
	# Add vào scene
	get_tree().current_scene.add_child(fireball)


func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	
	var nearest: Node2D = null
	var nearest_dist = INF
	
	for enemy in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	
	return nearest


# ═══════════════════════════════════════════════════════════════════════════
#                           LEVEL BONUSES
# ═══════════════════════════════════════════════════════════════════════════

func _get_level_bonus() -> Dictionary:
	var bonus = {"damage": 0.0, "area": 0.0, "amount": 0, "cooldown": 0.0}
	
	if current_level >= 2:
		bonus["damage"] += 0.3   # +30%
	if current_level >= 3:
		bonus["area"] += 0.2     # +20%
	if current_level >= 4:
		bonus["amount"] += 1
	if current_level >= 5:
		bonus["damage"] += 0.3   # +60% total
		bonus["cooldown"] += 0.1 # -10%
	if current_level >= 6:
		bonus["area"] += 0.3     # +50% total
	if current_level >= 7:
		bonus["amount"] += 1     # +2 total
	if current_level >= 8:
		bonus["damage"] += 0.3   # +90% total
		bonus["area"] += 0.3     # +80% total
	
	return bonus
