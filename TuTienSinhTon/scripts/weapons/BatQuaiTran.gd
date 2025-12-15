# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          BÁT QUÁI TRẬN (Bagua Formation)                   ║
# ║                    Orbit Weapon - Thổ Hệ                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Bát Quái Trận - 3-8 quả cầu xoay quanh player                          │
# │ Giống "Garlic"/"Bible" trong Vampire Survivors                          │
# │                                                                         │
# │ UPGRADE PATH:                                                           │
# │   Lv 1: 3 orbs                                                          │
# │   Lv 2: +10% damage                                                     │
# │   Lv 3: +1 orb                                                          │
# │   Lv 4: +10% rotation speed                                             │
# │   Lv 5: +1 orb                                                          │
# │   Lv 6: +20% damage                                                     │
# │   Lv 7: +1 orb                                                          │
# │   Lv 8: +1 orb (+20% area)                                              │
# └─────────────────────────────────────────────────────────────────────────┘

extends BaseWeapon


# ═══════════════════════════════════════════════════════════════════════════
#                              ORBIT SETTINGS
# ═══════════════════════════════════════════════════════════════════════════

@export var orbit_radius: float = 60.0 # Khoảng cách từ player
@export var rotation_speed: float = 2.0 # Rad/second
@export var orb_size: float = 15.0 # Kích thước mỗi orb

# Orb visual nodes
var orbs: Array[Node2D] = []
var current_angle: float = 0.0


# ═══════════════════════════════════════════════════════════════════════════
#                           INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Set weapon info
	weapon_id = "bat_quai_tran"
	weapon_name = "Bát Quái Trận"
	description = "Âm dương luân chuyển, bát quái hộ thân"
	
	# Orbit weapons không dùng cooldown thông thường
	base_damage = 15.0
	base_cooldown = 0.3 # Damage tick rate
	base_area = 1.0
	base_speed = 0.0 # Không cần
	base_duration = 0.0 # Continuous
	base_amount = 3 # Số orbs ban đầu
	base_pierce = 999 # Unlimited pierce
	base_knockback = 20.0
	
	max_level = 8
	
	# Gọi parent _ready()
	super._ready()
	
	# Tạo orbs
	_create_orbs()


func _create_orbs() -> void:
	# Clear existing
	for orb in orbs:
		orb.queue_free()
	orbs.clear()
	
	# Tạo mới theo current_amount
	for i in range(current_amount):
		var orb = _create_single_orb()
		orbs.append(orb)
		add_child(orb)


func _create_single_orb() -> Node2D:
	# Tạo visual node cho orb
	var orb = Node2D.new()
	
	# Visual: Circle shape
	var sprite = Sprite2D.new()
	# Dùng texture mặc định hoặc tạo ColorRect
	# Cho đơn giản, tạo polygon
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	var segments = 8
	for i in range(segments):
		var angle = (float(i) / segments) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * orb_size * current_area)
	polygon.polygon = points
	polygon.color = Color(0.2, 0.6, 0.9, 0.8) # Xanh dương sáng
	orb.add_child(polygon)
	
	# Hitbox cho orb
	var hitbox = Area2D.new()
	hitbox.collision_layer = 4 # Weapon layer
	hitbox.collision_mask = 2 # Enemy layer
	hitbox.body_entered.connect(_on_orb_hit_enemy)
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = orb_size * current_area
	collision.shape = shape
	
	hitbox.add_child(collision)
	orb.add_child(hitbox)
	
	return orb


# ═══════════════════════════════════════════════════════════════════════════
#                              PROCESS
# ═══════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Xoay orbs quanh player
	current_angle += rotation_speed * delta
	
	# Update vị trí mỗi orb
	var num_orbs = orbs.size()
	for i in range(num_orbs):
		var orb = orbs[i]
		var angle_offset = (float(i) / num_orbs) * TAU
		var orb_angle = current_angle + angle_offset
		
		orb.position = Vector2(
			cos(orb_angle) * orbit_radius,
			sin(orb_angle) * orbit_radius
		)
		
		# Xoay orb theo hướng di chuyển
		orb.rotation = orb_angle


func _on_orb_hit_enemy(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		# Gây damage
		var knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(current_damage, knockback_dir * current_knockback)
		
		# Emit damage number
		var is_crit = randf() < 0.1 # 10% crit chance
		var display_damage = int(current_damage * (1.5 if is_crit else 1.0))
		Events.show_damage_number.emit(display_damage, body.global_position, is_crit)


# ═══════════════════════════════════════════════════════════════════════════
#                              UPGRADE
# ═══════════════════════════════════════════════════════════════════════════

func upgrade() -> void:
	if current_level >= max_level:
		return
	
	current_level += 1
	
	# Apply upgrade theo level
	match current_level:
		2:
			current_damage *= 1.1 # +10% damage
		3:
			current_amount += 1 # +1 orb
			_create_orbs()
		4:
			rotation_speed *= 1.1 # +10% rotation
		5:
			current_amount += 1 # +1 orb
			_create_orbs()
		6:
			current_damage *= 1.2 # +20% damage
		7:
			current_amount += 1 # +1 orb
			_create_orbs()
		8:
			current_amount += 1 # +1 orb
			current_area *= 1.2 # +20% area
			_create_orbs()
	
	print("Bát Quái Trận upgraded to level ", current_level)


# Override _attack vì Orbit weapon không cần attack theo cách thông thường
func _attack() -> void:
	# Orbit weapon không fire projectiles
	# Damage xảy ra liên tục qua collision
	pass
