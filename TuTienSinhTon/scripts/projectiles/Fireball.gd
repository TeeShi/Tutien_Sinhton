# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              FIREBALL PROJECTILE                          ║
# ║                    Quả cầu lửa - Nổ khi chạm hoặc hết thời gian           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Area2D


# ═══════════════════════════════════════════════════════════════════════════
#                              PROPERTIES
# ═══════════════════════════════════════════════════════════════════════════

var direction: Vector2 = Vector2.RIGHT
var damage: float = 15.0
var speed: float = 250.0
var duration: float = 3.0
var explosion_radius: float = 80.0

var lifetime: float = 0.0
var has_exploded: bool = false


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Connect signal
	body_entered.connect(_on_body_entered)
	
	# Xoay sprite theo hướng
	rotation = direction.angle()


func setup(dir: Vector2, dmg: float, spd: float, dur: float, radius: float) -> void:
	direction = dir.normalized()
	damage = dmg
	speed = spd
	duration = dur
	explosion_radius = radius


# ═══════════════════════════════════════════════════════════════════════════
#                              PHYSICS
# ═══════════════════════════════════════════════════════════════════════════

func _physics_process(delta: float) -> void:
	if has_exploded:
		return
	
	# Di chuyển
	global_position += direction * speed * delta
	
	# Đếm thời gian sống
	lifetime += delta
	if lifetime >= duration:
		_explode()


# ═══════════════════════════════════════════════════════════════════════════
#                              COLLISION
# ═══════════════════════════════════════════════════════════════════════════

func _on_body_entered(body: Node2D) -> void:
	if has_exploded:
		return
	
	# Chạm enemy → nổ
	if body.is_in_group("enemies"):
		_explode()


# ═══════════════════════════════════════════════════════════════════════════
#                              EXPLOSION
# ═══════════════════════════════════════════════════════════════════════════

func _explode() -> void:
	if has_exploded:
		return
	
	has_exploded = true
	
	# Tìm tất cả enemies trong phạm vi nổ
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= explosion_radius:
			# Gây damage
			if enemy.has_method("take_damage"):
				var knockback_dir = (enemy.global_position - global_position).normalized()
				enemy.take_damage(damage, knockback_dir * 100)
	
	# TODO: Spawn explosion effect
	# var explosion = ExplosionEffect.instantiate()
	# explosion.global_position = global_position
	# get_tree().current_scene.add_child(explosion)
	
	# Xóa fireball
	queue_free()
