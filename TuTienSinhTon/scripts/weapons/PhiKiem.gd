# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          PHI KIEM (Flying Sword)                          ║
# ║                    Công Pháp Đầu Tiên - Kim Hệ                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Phi Kiếm - Kiếm bay ngang qua màn hình                                  │
# │                                                                         │
# │ Đây là weapon đơn giản nhất, giống "Whip" trong Vampire Survivors       │
# │ Perfect để demo hệ thống weapon!                                        │
# │                                                                         │
# │ UPGRADE PATH:                                                           │
# │   Lv 1: Base damage, 1 sword                                            │
# │   Lv 2: +20% damage                                                     │
# │   Lv 3: +1 sword                                                        │
# │   Lv 4: +1 pierce                                                       │
# │   Lv 5: +20% damage                                                     │
# │   Lv 6: +1 sword                                                        │
# │   Lv 7: +20% area                                                       │
# │   Lv 8: +1 sword                                                        │
# │                                                                         │
# │ EVOLUTION: Phi Kiếm + Kim Cương Thể = Vạn Kiếm Quy Tông                 │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseWeapon
# ↑ Kế thừa từ BaseWeapon, có tất cả properties và functions của nó!


# ═══════════════════════════════════════════════════════════════════════════
#                              CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════

# Preload projectile scene
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: preload vs load                                                │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ preload("path"):                                                        │
# │   - Load TẠI THỜI ĐIỂM COMPILE                                          │
# │   - Nhanh hơn khi runtime                                               │
# │   - Path phải là string literal (không phải variable)                   │
# │   - Dùng cho resources biết trước                                       │
# │                                                                         │
# │ load("path"):                                                           │
# │   - Load TẠI RUNTIME                                                    │
# │   - Có thể dùng dynamic path (variable)                                 │
# │   - Chậm hơn nhưng flexible hơn                                         │
# │                                                                         │
# │ RULE: Dùng preload nếu biết path lúc viết code                          │
# └─────────────────────────────────────────────────────────────────────────┘
const PROJECTILE_SCENE = preload("res://scenes/projectiles/SwordProjectile.tscn")


# ═══════════════════════════════════════════════════════════════════════════
#                           INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Set weapon info
	weapon_id = "phi_kiem"
	weapon_name = "Phi Kiếm"
	description = "Kiếm khí như rồng, chém ngang trời đất"
	
	# Set base stats (Level 1)
	base_damage = 15.0
	base_cooldown = 1.0
	base_area = 1.0
	base_speed = 300.0
	base_duration = 0.5
	base_amount = 1      # Số kiếm
	base_pierce = 1      # Xuyên qua 1 enemy
	base_knockback = 50.0
	
	max_level = 8
	
	# Gọi parent _ready()
	super._ready()
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: super()                                                    │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ super() = Gọi function CÙNG TÊN của class CHA                       │
	# │                                                                     │
	# │ Khi override _ready():                                              │
	# │   - Con có _ready() riêng                                           │
	# │   - Nhưng vẫn cần chạy code của cha                                 │
	# │   - → super._ready() gọi BaseWeapon._ready()                        │
	# │                                                                     │
	# │ THƯỜNG gọi super() ở ĐẦU hoặc CUỐI function                         │
	# │   - Đầu: Cha setup trước, con customize sau                         │
	# │   - Cuối: Con setup trước, cha finalize                             │
	# └─────────────────────────────────────────────────────────────────────┘


# ═══════════════════════════════════════════════════════════════════════════
#                              ATTACK
# ═══════════════════════════════════════════════════════════════════════════

func _attack() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ PHI KIẾM ATTACK PATTERN:                                            │
	# │                                                                     │
	# │ 1. Xác định hướng (về phía enemy gần nhất hoặc facing direction)    │
	# │ 2. Spawn kiếm(s) từ player                                          │
	# │ 3. Mỗi kiếm bay theo hướng đó                                       │
	# │                                                                     │
	# │ Ở đây tạm thời spawn theo hướng cuối cùng player di chuyển          │
	# └─────────────────────────────────────────────────────────────────────┘
	
	if not player:
		return
	
	# Xác định hướng attack
	var attack_direction = _get_attack_direction()
	
	# Spawn kiếm(s)
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Loop trong GDScript                                        │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ for i in range(n): → Lặp n lần (i từ 0 đến n-1)                     │
	# │ for i in range(start, end): → i từ start đến end-1                  │
	# │ for item in array: → Lặp qua từng item trong array                  │
	# │                                                                     │
	# │ VD: current_amount = 3                                              │
	# │   for i in range(3): # i = 0, 1, 2                                  │
	# │       spawn_sword()   # spawn 3 kiếm                                │
	# └─────────────────────────────────────────────────────────────────────┘
	for i in range(current_amount):
		_spawn_sword(attack_direction, i)
	
	print("Phi Kiếm attack! (", current_amount, " swords)")


func _get_attack_direction() -> Vector2:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ Chiến thuật targeting:                                              │
	# │ 1. Nếu có enemy gần → attack về phía enemy                          │
	# │ 2. Nếu không → attack theo hướng player đang nhìn                   │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Tìm enemy gần nhất
	var nearest_enemy = _find_nearest_enemy()
	
	if nearest_enemy:
		# Hướng về phía enemy
		return (nearest_enemy.global_position - player.global_position).normalized()
	else:
		# Hướng mặc định (phải hoặc trái dựa trên sprite flip)
		if player.sprite.flip_h:
			return Vector2.LEFT
		else:
			return Vector2.RIGHT


func _find_nearest_enemy() -> Node2D:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: get_tree().get_nodes_in_group()                            │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Godot có hệ thống GROUPS:                                           │
	# │   - Mỗi node có thể thuộc nhiều groups                              │
	# │   - Groups = "tags" để nhóm nodes                                   │
	# │                                                                     │
	# │ Thêm vào group:                                                     │
	# │   add_to_group("enemies")                                           │
	# │   Hoặc trong Editor: Node → Groups tab                              │
	# │                                                                     │
	# │ Lấy tất cả nodes trong group:                                       │
	# │   get_tree().get_nodes_in_group("enemies")                          │
	# │                                                                     │
	# │ Dùng cho: Tìm tất cả enemies, bullets, pickups, etc.                │
	# └─────────────────────────────────────────────────────────────────────┘
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_distance: float = INF  # INF = vô cực
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	
	return nearest


func _spawn_sword(direction: Vector2, index: int) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ Spawn pattern cho nhiều kiếm:                                       │
	# │   1 kiếm: Bay thẳng                                                 │
	# │   2 kiếm: Một trên, một dưới                                        │
	# │   3+ kiếm: Fan pattern (quạt)                                       │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Tính angle offset cho fan pattern
	var angle_offset = 0.0
	if current_amount > 1:
		# ┌─────────────────────────────────────────────────────────────────┐
		# │ BÀI HỌC: Spread pattern math                                    │
		# ├─────────────────────────────────────────────────────────────────┤
		# │ Với n projectiles, spread angle = 15 degrees mỗi cái            │
		# │                                                                 │
		# │ VD 3 projectiles:                                               │
		# │   index 0: -15°                                                 │
		# │   index 1: 0°                                                   │
		# │   index 2: +15°                                                 │
		# │                                                                 │
		# │ Công thức: angle = (index - center_index) * spread              │
		# │   center_index = (count - 1) / 2.0                              │
		# │   → 3 kiếm: center = 1.0                                        │
		# │   → index 0: (0 - 1) * 15 = -15°                                │
		# │   → index 1: (1 - 1) * 15 = 0°                                  │
		# │   → index 2: (2 - 1) * 15 = 15°                                 │
		# └─────────────────────────────────────────────────────────────────┘
		var spread_angle = deg_to_rad(15.0)  # 15 degrees thành radians
		var center_index = (current_amount - 1) / 2.0
		angle_offset = (index - center_index) * spread_angle
	
	# Rotate direction bằng offset
	var final_direction = direction.rotated(angle_offset)
	
	# Instantiate projectile
	# Lưu ý: Cần tạo SwordProjectile.tscn trước khi uncomment
	# var sword = PROJECTILE_SCENE.instantiate()
	# sword.global_position = player.global_position
	# sword.setup(final_direction, current_damage, current_speed, current_pierce, current_duration)
	# get_tree().current_scene.add_child(sword)
	
	# TẠM THỜI: Print debug thay vì spawn thực
	print("  → Sword ", index, " spawned, direction: ", final_direction)
	
	# TẠM THỜI: Gây damage cho enemy gần nhất (để test)
	var nearest = _find_nearest_enemy()
	if nearest and nearest.has_method("take_damage"):
		nearest.take_damage(current_damage, final_direction * base_knockback)


# ═══════════════════════════════════════════════════════════════════════════
#                        LEVEL BONUSES
# ═══════════════════════════════════════════════════════════════════════════

func _get_level_bonus() -> Dictionary:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ PHI KIẾM UPGRADE TABLE:                                             │
	# │                                                                     │
	# │ Lv 2: +20% damage                                                   │
	# │ Lv 3: +1 sword                                                      │
	# │ Lv 4: +1 pierce                                                     │
	# │ Lv 5: +20% damage                                                   │
	# │ Lv 6: +1 sword                                                      │
	# │ Lv 7: +20% area                                                     │
	# │ Lv 8: +1 sword                                                      │
	# │                                                                     │
	# │ Ở Level 8:                                                          │
	# │   damage: +40%                                                      │
	# │   amount: +3 (total 4 swords)                                       │
	# │   pierce: +1 (total 2)                                              │
	# │   area: +20%                                                        │
	# └─────────────────────────────────────────────────────────────────────┘
	
	var bonus = {
		"damage": 0.0,
		"amount": 0,
		"pierce": 0,
		"area": 0.0
	}
	
	# Accumulate bonuses từ level 2 đến current_level
	if current_level >= 2:
		bonus["damage"] += 0.2  # +20%
	if current_level >= 3:
		bonus["amount"] += 1
	if current_level >= 4:
		bonus["pierce"] += 1
	if current_level >= 5:
		bonus["damage"] += 0.2  # +40% total
	if current_level >= 6:
		bonus["amount"] += 1    # +2 total
	if current_level >= 7:
		bonus["area"] += 0.2    # +20%
	if current_level >= 8:
		bonus["amount"] += 1    # +3 total (4 swords)
	
	return bonus


# ═══════════════════════════════════════════════════════════════════════════
#                           EVOLUTION
# ═══════════════════════════════════════════════════════════════════════════

func get_required_passive_id() -> String:
	return "kim_cuong_the"  # Kim Cương Thể (Diamond Body)


func get_evolved_weapon_id() -> String:
	return "van_kiem_quy_tong"  # Vạn Kiếm Quy Tông (Ten Thousand Swords Return)
