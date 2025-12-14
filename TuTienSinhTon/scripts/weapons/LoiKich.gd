# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              LÔI KÍCH                                     ║
# ║                    Lightning - Sét đánh enemy ngẫu nhiên                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ MÔ TẢ:                                                                  │
# │ Đánh sét vào enemy ngẫu nhiên trong phạm vi                             │
# │ Damage cao, instant hit, không có projectile                            │
# │                                                                         │
# │ TƯƠNG TỰ: Lightning Ring trong Vampire Survivors                        │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseWeapon


# ═══════════════════════════════════════════════════════════════════════════
#                              CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════

const LIGHTNING_VISUAL = preload("res://scenes/projectiles/LightningStrike.tscn")


# ═══════════════════════════════════════════════════════════════════════════
#                              EXTRA PROPERTIES
# ═══════════════════════════════════════════════════════════════════════════

@export var strike_range: float = 300.0  # Phạm vi đánh sét


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Weapon info
	weapon_id = "loi_kich"
	weapon_name = "Lôi Kích"
	description = "Triệu hồi sét đánh vào kẻ địch ngẫu nhiên"
	
	# Base stats
	base_damage = 25.0       # Damage rất cao
	base_cooldown = 3.0      # Cooldown dài
	base_speed = 0.0         # Không dùng (instant)
	base_amount = 1          # Số lần đánh mỗi lượt
	base_pierce = 0          # Không dùng
	base_duration = 0.3      # Thời gian hiệu ứng visual
	base_area = 50.0         # Bán kính xung quanh điểm đánh
	
	super._ready()


# ═══════════════════════════════════════════════════════════════════════════
#                              ATTACK
# ═══════════════════════════════════════════════════════════════════════════

func _attack() -> void:
	if not player:
		return
	
	# Lấy danh sách enemies trong phạm vi
	var targets = _get_random_targets(current_amount)
	
	# Đánh sét vào từng target
	for target in targets:
		_strike_target(target)


func _get_random_targets(count: int) -> Array:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var in_range: Array = []
	
	# Lọc enemies trong phạm vi
	for enemy in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist <= strike_range:
			in_range.append(enemy)
	
	# Random chọn targets
	if in_range.is_empty():
		return []
	
	in_range.shuffle()
	return in_range.slice(0, min(count, in_range.size()))


func _strike_target(target: Node2D) -> void:
	if not is_instance_valid(target):
		return
	
	# Gây damage
	if target.has_method("take_damage"):
		var knockback_dir = (target.global_position - player.global_position).normalized()
		target.take_damage(current_damage, knockback_dir * 150)
	
	# Spawn visual effect
	_spawn_lightning_effect(target.global_position)
	
	# AoE damage xung quanh target
	_deal_aoe_damage(target.global_position, target)


func _deal_aoe_damage(center: Vector2, main_target: Node2D) -> void:
	if current_area <= 0:
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# Bỏ qua target chính (đã nhận damage)
		if enemy == main_target:
			continue
		
		var dist = center.distance_to(enemy.global_position)
		if dist <= current_area:
			# AoE damage = 50% damage chính
			if enemy.has_method("take_damage"):
				var knockback_dir = (enemy.global_position - center).normalized()
				enemy.take_damage(current_damage * 0.5, knockback_dir * 80)


func _spawn_lightning_effect(pos: Vector2) -> void:
	if not LIGHTNING_VISUAL:
		return
	
	var effect = LIGHTNING_VISUAL.instantiate()
	effect.global_position = pos
	effect.setup(current_duration)
	get_tree().current_scene.add_child(effect)


# ═══════════════════════════════════════════════════════════════════════════
#                           LEVEL BONUSES
# ═══════════════════════════════════════════════════════════════════════════

func _get_level_bonus() -> Dictionary:
	var bonus = {"damage": 0.0, "area": 0.0, "amount": 0, "cooldown": 0.0}
	
	if current_level >= 2:
		bonus["damage"] += 0.4   # +40%
	if current_level >= 3:
		bonus["amount"] += 1
	if current_level >= 4:
		bonus["area"] += 0.3     # +30%
	if current_level >= 5:
		bonus["damage"] += 0.4   # +80% total
		bonus["cooldown"] += 0.15 # -15%
	if current_level >= 6:
		bonus["amount"] += 1     # +2 total
	if current_level >= 7:
		bonus["area"] += 0.3     # +60% total
	if current_level >= 8:
		bonus["damage"] += 0.4   # +120% total
		bonus["amount"] += 2     # +4 total
	
	return bonus
