# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              XP GEM                                       ║
# ║                 Gem XP drop từ enemy, player hút và collect               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Pickup System và "Juice"                                       │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ PICKUP LÀ GÌ?                                                           │
# │   - Item rơi ra từ enemy/chest                                          │
# │   - Player nhặt để nhận lợi ích (XP, gold, health, etc.)                │
# │                                                                         │
# │ "JUICE" - CẢM GIÁC THỎA MÃN KHI NHẶT:                                   │
# │   1. Visual: Gem sáng, có animation                                     │
# │   2. Movement: Bay về phía player (magnet effect)                       │
# │   3. Sound: Tiếng "ding" khi nhặt (để sau)                              │
# │   4. Feedback: XP bar tăng lên                                          │
# │                                                                         │
# │ MAGNET PATTERN:                                                         │
# │   - Player có "vùng hút" (MagnetArea)                                   │
# │   - Gem ở trong vùng → Bay về player                                    │
# │   - Classic Vampire Survivors mechanic!                                 │
# └─────────────────────────────────────────────────────────────────────────┘

extends Area2D
class_name XPGem


# ═══════════════════════════════════════════════════════════════════════════
#                              SETTINGS
# ═══════════════════════════════════════════════════════════════════════════

## Giá trị XP của gem này
@export var xp_value: int = 1

## Tốc độ bay về player khi bị hút
@export var magnet_speed: float = 300.0

## Tốc độ văng ra ban đầu
@export var scatter_speed: float = 100.0


# ═══════════════════════════════════════════════════════════════════════════
#                              STATE
# ═══════════════════════════════════════════════════════════════════════════

var is_attracted: bool = false   # Đang bị hút về player?
var target_player: Node2D = null  # Player đang hút
var velocity: Vector2 = Vector2.ZERO  # Vận tốc hiện tại


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Văng ra 1 hướng random khi spawn
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Vector2.from_angle()                                       │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Tạo vector đơn vị (length=1) từ góc (radians)                       │
	# │                                                                     │
	# │ randf() * TAU:                                                      │
	# │   - randf() = random 0.0 → 1.0                                      │
	# │   - TAU = 2π = 360 độ (full circle)                                 │
	# │   → Random góc từ 0 đến 360 độ                                      │
	# │                                                                     │
	# │ VD: angle = π/4 → Vector pointing top-right                         │
	# └─────────────────────────────────────────────────────────────────────┘
	var random_angle = randf() * TAU
	velocity = Vector2.from_angle(random_angle) * scatter_speed
	
	# Connect signal khi chạm player
	body_entered.connect(_on_body_entered)


func setup(value: int) -> void:
	## Thiết lập giá trị XP khi spawn
	xp_value = value


# ═══════════════════════════════════════════════════════════════════════════
#                              PHYSICS
# ═══════════════════════════════════════════════════════════════════════════

func _physics_process(delta: float) -> void:
	if is_attracted and target_player and is_instance_valid(target_player):
		# Đang bị hút → Bay về player
		# ┌─────────────────────────────────────────────────────────────────┐
		# │ BÀI HỌC: direction_to() và move_toward()                        │
		# ├─────────────────────────────────────────────────────────────────┤
		# │ direction_to(target):                                           │
		# │   - Trả về vector đơn vị chỉ về target                          │
		# │   - VD: gem ở (0,0), player ở (100,0)                           │
		# │       → direction = (1, 0) = phải                               │
		# │                                                                 │
		# │ magnet_speed * delta:                                           │
		# │   - Tốc độ * thời gian = quãng đường                            │
		# │   - Đảm bảo tốc độ đều ở mọi FPS                                 │
		# └─────────────────────────────────────────────────────────────────┘
		var direction = global_position.direction_to(target_player.global_position)
		var distance = global_position.distance_to(target_player.global_position)
		
		# Tăng tốc khi gần player (feel more "snappy")
		var speed_multiplier = 1.0 + (1.0 - clamp(distance / 200.0, 0.0, 1.0))
		velocity = direction * magnet_speed * speed_multiplier
	else:
		# Không bị hút → Chậm dần và dừng
		velocity = velocity.move_toward(Vector2.ZERO, 200.0 * delta)
	
	# Di chuyển
	global_position += velocity * delta


# ═══════════════════════════════════════════════════════════════════════════
#                           MAGNET SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

## Được gọi khi gem vào vùng hút của player
func attract_to(player: Node2D) -> void:
	is_attracted = true
	target_player = player


func _on_body_entered(body: Node2D) -> void:
	# Chỉ collect khi chạm player
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: queue_free()                                               │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ queue_free() = Đánh dấu node để xóa cuối frame                      │
	# │                                                                     │
	# │ TẠI SAO KHÔNG DÙNG free()?                                          │
	# │   - free() xóa NGAY LẬP TỨC                                         │
	# │   - Có thể gây crash nếu còn code đang chạy                         │
	# │   - queue_free() an toàn hơn, chờ xong frame mới xóa                │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Thêm XP cho player
	GameManager.add_xp(xp_value)
	Events.xp_gem_collected.emit(xp_value)
	
	# Xóa gem
	queue_free()
