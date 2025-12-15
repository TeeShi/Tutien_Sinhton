# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          BASE ENEMY                                       ║
# ║                Yêu Ma Cơ Bản - Abstract Base Class                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Tương tự như BaseWeapon, đây là class cha cho tất cả enemy types        │
# │                                                                         │
# │ HIERARCHY:                                                              │
# │   BaseEnemy (abstract)                                                  │
# │   ├── YeuTrung (Swarm - basic enemies)                                  │
# │   │   ├── TieuYeuTrung                                                  │
# │   │   ├── CuongThi                                                      │
# │   │   └── ...                                                           │
# │   ├── YeuThu (Elite - stronger)                                         │
# │   │   ├── YeuLang                                                       │
# │   │   └── ...                                                           │
# │   └── YeuVuong (Boss)                                                   │
# │       ├── BachCotTinh                                                   │
# │       └── ...                                                           │
# └─────────────────────────────────────────────────────────────────────────┘

extends CharacterBody2D
class_name BaseEnemy


# ═══════════════════════════════════════════════════════════════════════════
#                              ENUMS
# ═══════════════════════════════════════════════════════════════════════════

enum EnemyType {
	SWARM, # Yêu Trùng - rất nhiều, yếu
	ELITE, # Yêu Thú - ít, mạnh hơn
	BOSS # Yêu Vương - hiếm, rất mạnh
}


# ═══════════════════════════════════════════════════════════════════════════
#                              EXPORTS
# ═══════════════════════════════════════════════════════════════════════════

@export_group("Enemy Info")
@export var enemy_id: String = "base_enemy"
@export var enemy_name: String = "Yêu Ma"
@export var enemy_type: EnemyType = EnemyType.SWARM

@export_group("Stats")
@export var max_hp: int = 10
@export var damage: int = 5 # Damage gây cho player khi chạm
@export var move_speed: float = 50.0
@export var xp_value: int = 1 # XP drop khi chết
@export var gold_value: int = 0 # Gold drop khi chết

@export_group("Combat")
@export var attack_cooldown: float = 0.5 # Thời gian giữa các lần gây damage
@export var knockback_resistance: float = 0.0 # 0 = bị đẩy full, 1 = không bị đẩy


# ═══════════════════════════════════════════════════════════════════════════
#                           INTERNAL STATE
# ═══════════════════════════════════════════════════════════════════════════

var current_hp: int = 10
var is_dead: bool = false
var target: Node2D = null # Thường là player
var attack_timer: float = 0.0 # Cooldown giữa các lần attack
var can_attack: bool = true


# ═══════════════════════════════════════════════════════════════════════════
#                           REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox # Area để detect player collision

# Debug
const DEBUG_SHOW_NAMES: bool = true # Toggle để hiển thị tên enemy
var name_label: Label = null


# ═══════════════════════════════════════════════════════════════════════════
#                           LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Add to enemies group (để weapons có thể tìm thấy)
	add_to_group("enemies")
	
	# Initialize HP
	current_hp = max_hp
	
	# Set target là player
	target = GameManager.player
	
	# Debug: Hiển thị tên enemy
	if DEBUG_SHOW_NAMES:
		_create_name_label()
	
	# Connect hitbox signal
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Connecting Signals trong code                             │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Thay vì connect trong Editor (Inspector → Signals)                  │
	# │ Ta có thể connect bằng code:                                        │
	# │                                                                     │
	# │   node.signal_name.connect(callable)                                │
	# │                                                                     │
	# │ callable = function để gọi khi signal phát                          │
	# │   - _on_hitbox_body_entered                                         │
	# │   - Hoặc dùng lambda: func(body): do_something(body)                │
	# │                                                                     │
	# │ Area2D.body_entered: Phát khi CharacterBody2D/RigidBody2D đi vào    │
	# │ Area2D.area_entered: Phát khi Area2D khác đi vào                    │
	# └─────────────────────────────────────────────────────────────────────┘
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# Notify spawn
	Events.enemy_spawned.emit(self)


func _create_name_label() -> void:
	name_label = Label.new()
	name_label.text = enemy_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-30, -30) # Phía trên đầu
	
	var settings = LabelSettings.new()
	settings.font_size = 10
	settings.font_color = Color.WHITE
	settings.outline_size = 2
	settings.outline_color = Color.BLACK
	name_label.label_settings = settings
	
	add_child(name_label)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Chỉ chạy khi game đang chơi
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Di chuyển về phía target
	_move_towards_target(delta)
	
	# Update attack cooldown
	_update_attack_cooldown(delta)


# ═══════════════════════════════════════════════════════════════════════════
#                           MOVEMENT
# ═══════════════════════════════════════════════════════════════════════════

func _move_towards_target(_delta: float) -> void:
	if not target or not is_instance_valid(target):
		return
	
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Vector Math cơ bản                                        │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ DIRECTION = Target Position - My Position                           │
	# │                                                                     │
	# │ VÍ DỤ:                                                              │
	# │   Enemy tại (100, 100)                                              │
	# │   Player tại (300, 200)                                             │
	# │   Direction = (300-100, 200-100) = (200, 100)                       │
	# │                                                                     │
	# │ NORMALIZE = Làm vector có độ dài = 1                                │
	# │   (200, 100).normalized() ≈ (0.89, 0.45)                            │
	# │                                                                     │
	# │ Tại sao normalize?                                                  │
	# │   - Chỉ giữ HƯỚNG, bỏ khoảng cách                                   │
	# │   - Tốc độ không phụ thuộc vào khoảng cách đến target               │
	# │                                                                     │
	# │ VELOCITY = Direction × Speed                                        │
	# │   velocity = (0.89, 0.45) × 50 = (44.5, 22.5) pixels/giây           │
	# └─────────────────────────────────────────────────────────────────────┘
	
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	
	# Flip sprite theo hướng di chuyển
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


# ═══════════════════════════════════════════════════════════════════════════
#                           COMBAT
# ═══════════════════════════════════════════════════════════════════════════

func _update_attack_cooldown(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true


func _on_hitbox_body_entered(body: Node2D) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Type checking với "is"                                    │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ body is Player → Trả về true nếu body là instance của class Player │
	# │                                                                     │
	# │ Đây là cách an toàn để check type trước khi gọi methods             │
	# │ Tránh runtime error khi body không phải Player                      │
	# └─────────────────────────────────────────────────────────────────────┘
	if body is Player and can_attack:
		# Gây damage cho player
		body.take_damage(damage)
		
		# Start cooldown
		can_attack = false
		attack_timer = attack_cooldown


## Nhận damage từ weapon
func take_damage(amount: float, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	
	# Tính damage thực tế (có thể thêm armor sau)
	var actual_damage = int(amount)
	current_hp -= actual_damage
	
	# Show damage number
	Events.show_damage_number.emit(actual_damage, global_position, false)
	
	# Play hit sound
	SoundManager.play_hit()
	
	# Knockback
	if knockback_direction != Vector2.ZERO:
		var knockback_force = knockback_direction * (1.0 - knockback_resistance)
		velocity += knockback_force
		# Knockback sẽ được xử lý trong _physics_process tiếp theo
	
	# Flash effect khi bị hit (optional, implement sau)
	_flash_white()
	
	# Check death
	if current_hp <= 0:
		_die()


## Flash trắng khi bị hit (feedback visual)
func _flash_white() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ TODO: Implement flash effect                                        │
	# │ Có thể dùng Shader hoặc Tween để đổi màu sprite                     │
	# └─────────────────────────────────────────────────────────────────────┘
	pass


## Enemy chết
func _die() -> void:
	if is_dead:
		return
	
	is_dead = true
	
	# Disable collision
	collision.set_deferred("disabled", true)
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: set_deferred()                                             │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Một số thay đổi KHÔNG THỂ làm trong physics callback                │
	# │ (như đang trong _physics_process hoặc collision callback)           │
	# │                                                                     │
	# │ set_deferred() = "Để sau, làm khi an toàn"                          │
	# │ Godot sẽ apply thay đổi này ở cuối frame                            │
	# │                                                                     │
	# │ LỖI phổ biến: Cannot change shape during physics step               │
	# │ → Giải pháp: set_deferred()                                         │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Drop XP
	_drop_xp()
	
	# Drop Gold (if any)
	_drop_gold()
	
	# Notify
	GameManager.register_enemy_kill()
	
	print(enemy_name, " defeated!")
	
	# Death animation rồi xóa
	# TODO: Play death animation
	queue_free()
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ queue_free() = Đánh dấu node để xóa ở cuối frame                    │
	# │ Khác với free() - xóa NGAY LẬP TỨC (có thể gây lỗi)                 │
	# │                                                                     │
	# │ LUÔN dùng queue_free() thay vì free() trong gameplay code           │
	# └─────────────────────────────────────────────────────────────────────┘


func _drop_xp() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Spawning Objects (Instantiate)                             │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Để spawn object mới trong Godot:                                    │
	# │                                                                     │
	# │ 1. Load scene:                                                      │
	# │    var XPGem = preload("res://scenes/pickups/XPGem.tscn")           │
	# │                                                                     │
	# │ 2. Instantiate (tạo instance mới):                                  │
	# │    var gem = XPGem.instantiate()                                    │
	# │                                                                     │
	# │ 3. Set position và properties:                                      │
	# │    gem.global_position = my_position                                │
	# │    gem.value = 5                                                    │
	# │                                                                     │
	# │ 4. Add vào scene tree:                                              │
	# │    get_tree().current_scene.add_child(gem)                          │
	# │    HOẶC parent_node.add_child(gem)                                  │
	# │                                                                     │
	# │ QUAN TRỌNG:                                                         │
	# │   - Phải add_child() thì object mới tồn tại trong game              │
	# │   - Object mới tạo chưa có parent = chưa trong scene tree           │
	# └─────────────────────────────────────────────────────────────────────┘
	if xp_value <= 0:
		return
	
	# Spawn XP gem(s) tại vị trí chết
	var XP_GEM_SCENE = preload("res://scenes/pickups/XPGem.tscn")
	
	# Số gem = xp_value / 5, tối thiểu 1, tối đa 10
	var gem_count = clampi(xp_value / 5, 1, 10)
	var xp_per_gem = xp_value / gem_count
	
	for i in range(gem_count):
		var gem = XP_GEM_SCENE.instantiate()
		gem.global_position = global_position
		gem.setup(xp_per_gem)
		# ┌─────────────────────────────────────────────────────────────────┐
		# │ BÀI HỌC: call_deferred()                                        │
		# ├─────────────────────────────────────────────────────────────────┤
		# │ Khi đang trong physics callback (như _die() từ collision)       │
		# │ không thể add_child() ngay vì Godot đang "flushing queries"     │
		# │                                                                 │
		# │ call_deferred() = "Làm việc này SAU khi frame xong"             │
		# │ An toàn hơn, tránh crash                                        │
		# └─────────────────────────────────────────────────────────────────┘
		get_tree().current_scene.call_deferred("add_child", gem)


func _drop_gold() -> void:
	if gold_value <= 0:
		return
	
	# Add gold to meta progression (vĩnh viễn)
	MetaManager.add_gold(gold_value)
