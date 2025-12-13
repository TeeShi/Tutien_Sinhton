# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          SWORD PROJECTILE                                 ║
# ║                    Projectile bay từ Phi Kiếm                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Area2D


# ═══════════════════════════════════════════════════════════════════════════
#                              VARIABLES
# ═══════════════════════════════════════════════════════════════════════════

var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var speed: float = 300.0
var pierce: int = 1          # Số enemy có thể xuyên qua
var duration: float = 2.0    # Thời gian tồn tại (giây)
var knockback: float = 50.0

var enemies_hit: Array = []  # Track enemies đã hit để không hit lại
var timer: float = 0.0


# ═══════════════════════════════════════════════════════════════════════════
#                           INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Connect signal khi va chạm với body
	body_entered.connect(_on_body_entered)
	
	# Rotate sprite theo hướng bay
	rotation = direction.angle()
	
	# Add vào group để dễ quản lý
	add_to_group("projectiles")


## Setup projectile với các thông số
func setup(dir: Vector2, dmg: float, spd: float, prc: int, dur: float, kb: float = 50.0) -> void:
	direction = dir.normalized()
	damage = dmg
	speed = spd
	pierce = prc
	duration = dur
	knockback = kb


# ═══════════════════════════════════════════════════════════════════════════
#                              MOVEMENT
# ═══════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	# Di chuyển theo hướng
	global_position += direction * speed * delta
	
	# Count down duration
	timer += delta
	if timer >= duration:
		_destroy()


# ═══════════════════════════════════════════════════════════════════════════
#                              COLLISION
# ═══════════════════════════════════════════════════════════════════════════

func _on_body_entered(body: Node2D) -> void:
	# Check nếu là enemy
	if not body.is_in_group("enemies"):
		return
	
	# Check nếu đã hit enemy này rồi
	if body in enemies_hit:
		return
	
	# Gây damage
	if body.has_method("take_damage"):
		body.take_damage(damage, direction * knockback)
	
	# Track enemy đã hit
	enemies_hit.append(body)
	
	# Giảm pierce
	pierce -= 1
	
	# Destroy nếu hết pierce
	if pierce <= 0:
		_destroy()


func _destroy() -> void:
	# Có thể thêm hiệu ứng fade/particle ở đây
	queue_free()
