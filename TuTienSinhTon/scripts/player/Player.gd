# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              PLAYER                                       ║
# ║                    Tu Sĩ - The Cultivator                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: CharacterBody2D là gì?                                         │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Godot có nhiều loại Node cho nhân vật:                                  │
# │                                                                         │
# │ 1. Node2D         → Cơ bản nhất, không có physics                       │
# │ 2. CharacterBody2D → Có physics, ĐIỀU KHIỂN bằng code (player, NPC)     │
# │ 3. RigidBody2D    → Physics tự động (vật rơi, bóng, ragdoll)            │
# │ 4. Area2D         → Detect va chạm, KHÔNG chặn đường                    │
# │                                                                         │
# │ Cho PLAYER, ta dùng CharacterBody2D vì:                                 │
# │   - Có collision với tường/obstacles                                    │
# │   - Di chuyển bằng code (không phải physics engine quyết định)          │
# │   - Có hàm move_and_slide() tiện lợi                                    │
# └─────────────────────────────────────────────────────────────────────────┘

extends CharacterBody2D
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ TIP: class_name cho phép tham chiếu class này ở nơi khác               │
# │ VD: var player: Player = $Player                                        │
# └─────────────────────────────────────────────────────────────────────────┘
class_name Player


# ═══════════════════════════════════════════════════════════════════════════
#                              EXPORTS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: @export là gì?                                                 │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ @export = Hiện biến này trong Godot Inspector panel                     │
# │                                                                         │
# │ LỢI ÍCH:                                                                │
# │   - Điều chỉnh giá trị KHÔNG cần sửa code                               │
# │   - Designer/Artist có thể tweak                                        │
# │   - Khác instances có thể có giá trị khác nhau                          │
# │                                                                         │
# │ CÚ PHÁP:                                                                │
# │   @export var speed: float = 100.0                                      │
# │   @export_range(0, 100) var health: int = 50  # Có slider               │
# │   @export_group("Movement")  # Nhóm các export                          │
# └─────────────────────────────────────────────────────────────────────────┘

@export_group("Base Stats")
@export var base_max_hp: int = 100 # Máu tối đa cơ bản
@export var base_move_speed: float = 200.0 # Tốc độ di chuyển cơ bản
@export var base_recovery: float = 0.0 # HP hồi/giây cơ bản

@export_group("Pickup")
@export var base_magnet_radius: float = 50.0 # Bán kính hút XP/Gold


# ═══════════════════════════════════════════════════════════════════════════
#                           CURRENT STATS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Stats HIỆN TẠI = Base + PowerUp bonuses + Passive bonuses               │
# │ Được tính lại mỗi khi có thay đổi                                       │
# └─────────────────────────────────────────────────────────────────────────┘

var current_hp: int = 100
var max_hp: int = 100
var move_speed: float = 200.0
var recovery: float = 0.0
var magnet_radius: float = 50.0

# Stat multipliers (từ passives và powerups)
var might_multiplier: float = 1.0 # Nhân damage
var damage_multiplier: float = 1.0 # Từ MetaManager PowerUps
var area_multiplier: float = 1.0 # Nhân AoE size
var speed_multiplier: float = 1.0 # Nhân projectile speed
var duration_multiplier: float = 1.0 # Nhân effect duration
var cooldown_multiplier: float = 1.0 # Nhân cooldown (< 1 = faster)
var xp_multiplier: float = 1.0 # Nhân XP gained


# ═══════════════════════════════════════════════════════════════════════════
#                           REFERENCES
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: @onready là gì?                                                │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ @onready = Gán giá trị KHI NODE READY (sau _ready())                    │
# │                                                                         │
# │ TẠI SAO cần @onready?                                                   │
# │   - Child nodes chưa tồn tại khi script load                            │
# │   - $ChildName chỉ hoạt động sau khi node vào scene tree                │
# │                                                                         │
# │ KHÔNG dùng @onready:                                                    │
# │   var sprite = $Sprite2D  # LỖI! Sprite2D chưa tồn tại                  │
# │                                                                         │
# │ DÙNG @onready:                                                          │
# │   @onready var sprite = $Sprite2D  # OK! Chờ đến _ready()               │
# │                                                                         │
# │ $ là shortcut cho get_node():                                           │
# │   $Sprite2D = get_node("Sprite2D")                                      │
# └─────────────────────────────────────────────────────────────────────────┘

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var magnet_area: Area2D = $MagnetArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var weapon_container: Node2D = $WeaponContainer
# ↑ Container chứa tất cả weapons của player


# ═══════════════════════════════════════════════════════════════════════════
#                           INTERNAL STATE
# ═══════════════════════════════════════════════════════════════════════════

var input_direction: Vector2 = Vector2.ZERO # Hướng input hiện tại
var is_invincible: bool = false # Bất tử (sau khi bị hit)
var invincibility_timer: float = 0.0
var recovery_accumulator: float = 0.0 # Tích lũy HP hồi (vì HP là int)

const INVINCIBILITY_DURATION: float = 0.5 # 0.5 giây bất tử sau hit


# ═══════════════════════════════════════════════════════════════════════════
#                           LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Đăng ký player với GameManager
	GameManager.player = self
	
	# Thêm vào group "player" để pickups có thể detect
	add_to_group("player")
	
	# Initialize stats
	_calculate_stats()
	current_hp = max_hp
	
	# Phát signal
	Events.player_spawned.emit(self)
	Events.player_health_changed.emit(current_hp, max_hp)
	
	# Connect MagnetArea để hút XP gems
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Magnet System cho Pickups                                 │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ MagnetArea là Area2D xung quanh player                              │
	# │ Khi pickup (XPGem) vào vùng này → attract_to(player)                │
	# │ Pickup sẽ bay về player, không cần player chạy đến                  │
	# │                                                                     │
	# │ TẠI SAO DÙNG area_entered THAY VÌ body_entered?                     │
	# │   - XPGem là Area2D (không phải CharacterBody2D)                    │
	# │   - body_entered chỉ detect physics bodies                          │
	# │   - area_entered detect Area2D với Area2D                           │
	# └─────────────────────────────────────────────────────────────────────┘
	var magnet_area_node = get_node_or_null("MagnetArea")
	if magnet_area_node:
		magnet_area_node.area_entered.connect(_on_magnet_area_entered)
		print("[DEBUG] MagnetArea connected! Collision mask: ", magnet_area_node.collision_mask)
	else:
		push_error("MagnetArea not found!")
	
	# Connect level up để tăng magnet
	Events.level_up_ended.connect(_on_level_up)
	
	print("Player spawned at ", global_position)


func _physics_process(delta: float) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: _physics_process vs _process                               │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ _process(delta):                                                    │
	# │   - Chạy mỗi RENDER frame                                           │
	# │   - FPS có thể thay đổi (30-144+)                                   │
	# │   - Dùng cho: UI, animation, visual effects                         │
	# │                                                                     │
	# │ _physics_process(delta):                                            │
	# │   - Chạy mỗi PHYSICS frame (cố định, mặc định 60/s)                 │
	# │   - Ổn định, không phụ thuộc FPS                                    │
	# │   - Dùng cho: MOVEMENT, collision, physics                          │
	# │                                                                     │
	# │ → Player movement PHẢI ở _physics_process!                          │
	# └─────────────────────────────────────────────────────────────────────┘
	# Xử lý input
	_handle_input()
	
	# Di chuyển
	_move(delta)
	
	# HP Recovery
	_handle_recovery(delta)
	
	# Invincibility countdown
	_handle_invincibility(delta)


# ═══════════════════════════════════════════════════════════════════════════
#                           INPUT HANDLING
# ═══════════════════════════════════════════════════════════════════════════

func _handle_input() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Input.get_vector()                                         │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Cách CŨ (verbose):                                                  │
	# │   var dir = Vector2.ZERO                                            │
	# │   if Input.is_action_pressed("move_right"): dir.x += 1              │
	# │   if Input.is_action_pressed("move_left"): dir.x -= 1               │
	# │   if Input.is_action_pressed("move_down"): dir.y += 1               │
	# │   if Input.is_action_pressed("move_up"): dir.y -= 1                 │
	# │                                                                     │
	# │ Cách MỚI (1 dòng):                                                  │
	# │   var dir = Input.get_vector("left", "right", "up", "down")         │
	# │                                                                     │
	# │ Trả về Vector2 đã NORMALIZED (độ dài = 1)                           │
	# │ → Di chuyển chéo không nhanh hơn di chuyển thẳng                    │
	# └─────────────────────────────────────────────────────────────────────┘
	input_direction = Input.get_vector(
		"move_left", # Negative X
		"move_right", # Positive X
		"move_up", # Negative Y (↑ trong Godot là -Y!)
		"move_down" # Positive Y
	)


# ═══════════════════════════════════════════════════════════════════════════
#                           MOVEMENT
# ═══════════════════════════════════════════════════════════════════════════

func _move(_delta: float) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: velocity và move_and_slide()                               │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ CharacterBody2D có biến built-in: velocity (Vector2)                │
	# │                                                                     │
	# │ velocity = Hướng + Tốc độ mà nhân vật muốn di chuyển                │
	# │                                                                     │
	# │ move_and_slide():                                                   │
	# │   - Dùng velocity để di chuyển                                      │
	# │   - Tự động xử lý collision                                         │
	# │   - "Slide" dọc tường thay vì dừng đột ngột                         │
	# │   - Trả về true nếu có collision                                    │
	# │                                                                     │
	# │ Công thức: velocity = direction * speed                             │
	# │ VD: Đi phải (1, 0) * 200 = (200, 0) pixels/giây                     │
	# └─────────────────────────────────────────────────────────────────────┘
	velocity = input_direction * move_speed
	move_and_slide()
	
	# Flip sprite dựa trên hướng di chuyển
	if input_direction.x != 0:
		sprite.flip_h = input_direction.x < 0


# ═══════════════════════════════════════════════════════════════════════════
#                           HP & DAMAGE
# ═══════════════════════════════════════════════════════════════════════════

func _handle_recovery(delta: float) -> void:
	# Hồi HP theo thời gian
	if recovery > 0 and current_hp < max_hp:
		# Tích lũy HP hồi (vì HP là int, mỗi frame chỉ hồi 0.016...)
		recovery_accumulator += recovery * delta
		
		# Khi tích lũy đủ 1 HP, heal và reset
		if recovery_accumulator >= 1.0:
			var heal_amount = int(recovery_accumulator)
			recovery_accumulator -= heal_amount
			heal(float(heal_amount))
	else:
		# Reset accumulator khi full HP
		recovery_accumulator = 0.0


func _handle_invincibility(delta: float) -> void:
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			# Có thể thêm visual effect hết invincibility


## Nhận damage từ enemy
func take_damage(amount: int) -> void:
	# Không nhận damage khi đang bất tử
	if is_invincible:
		return
	
	# Giảm HP
	current_hp -= amount
	current_hp = max(0, current_hp) # Không xuống dưới 0
	
	# Phát signal
	Events.player_health_changed.emit(current_hp, max_hp)
	Events.show_damage_number.emit(amount, global_position, false)
	Events.player_damaged.emit(amount, current_hp) # For camera shake
	
	# Play hurt sound
	SoundManager.play_player_hurt()
	
	print("Player took ", amount, " damage! HP: ", current_hp, "/", max_hp)
	
	# Bật invincibility
	is_invincible = true
	invincibility_timer = INVINCIBILITY_DURATION
	# TODO: Thêm flash effect
	
	# Check death
	if current_hp <= 0:
		_die()


## Hồi HP
func heal(amount: float) -> void:
	var old_hp = current_hp
	current_hp = min(current_hp + int(amount), max_hp)
	
	if current_hp != old_hp:
		Events.player_health_changed.emit(current_hp, max_hp)


## Chết
func _die() -> void:
	print("Player DIED!")
	Events.player_died.emit()
	GameManager.end_run(false)
	# TODO: Death animation, disable input


# ═══════════════════════════════════════════════════════════════════════════
#                           STAT CALCULATION
# ═══════════════════════════════════════════════════════════════════════════

## Tính toán lại tất cả stats
## Gọi khi có powerup mới hoặc passive thay đổi
func _calculate_stats() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ CÔNG THỨC:                                                          │
	# │ Final Stat = Base Stat × (1 + PowerUp Bonus + Passive Bonus)        │
	# │                                                                     │
	# │ VÍ DỤ:                                                              │
	# │   Base HP: 100                                                      │
	# │   PowerUp: +20% Max HP                                              │
	# │   Passive "Linh Thạch Hộ Tâm" Lv3: +60% Max HP                      │
	# │   → Final HP = 100 × (1 + 0.2 + 0.6) = 180                          │
	# └─────────────────────────────────────────────────────────────────────┘
	# TODO: Lấy bonuses từ PowerUp system và Passive system
	# Tạm thời dùng base stats
	max_hp = base_max_hp
	move_speed = base_move_speed
	recovery = base_recovery
	magnet_radius = base_magnet_radius
	
	# Update magnet area collision radius
	# (Sẽ implement sau khi có MagnetArea)


## Thêm stat multiplier (từ passive)
func add_stat_multiplier(stat: String, value: float) -> void:
	match stat:
		"might": might_multiplier += value
		"area": area_multiplier += value
		"speed": speed_multiplier += value
		"duration": duration_multiplier += value
		"cooldown": cooldown_multiplier -= value # -cooldown = faster
	
	# Recalculate weapons
	_notify_weapons_stat_changed()


func _notify_weapons_stat_changed() -> void:
	# Notify tất cả weapons về stat change
	for weapon in weapon_container.get_children():
		if weapon.has_method("recalculate_stats"):
			weapon.recalculate_stats()


## Thêm HP regen rate
func add_hp_regen(amount: float) -> void:
	recovery += amount
	print("HP Regen increased to: ", recovery, " HP/s")


## Khi pickup vào vùng hút
func _on_magnet_area_entered(area: Area2D) -> void:
	print("[DEBUG] Magnet detected: ", area.name, " - has attract_to: ", area.has_method("attract_to"))
	# Check nếu là XPGem (có method attract_to)
	if area.has_method("attract_to"):
		area.attract_to(self)
		print("[DEBUG] Attracting gem to player!")


## Khi level up xong, tăng magnet radius
func _on_level_up() -> void:
	# Tăng magnet radius 5% mỗi level
	var shape = magnet_area.get_node("CollisionShape2D").shape
	if shape is CircleShape2D:
		shape.radius *= 1.05
		print("Magnet radius increased to: ", shape.radius)
