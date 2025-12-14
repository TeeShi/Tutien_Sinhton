# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          MAGNET VISUAL                                    ║
# ║              Vẽ đường viền mờ hiển thị vùng hút XP                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Custom Drawing với _draw()                                    │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ _draw() được gọi khi Godot render node này                              │
# │ Bạn có thể vẽ bất cứ gì: lines, circles, arcs, polygons...              │
# │                                                                         │
# │ Khi cần update hình vẽ, gọi queue_redraw()                              │
# │ Godot sẽ gọi lại _draw() ở frame tiếp theo                              │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node2D


# ═══════════════════════════════════════════════════════════════════════════
#                              SETTINGS
# ═══════════════════════════════════════════════════════════════════════════

## Màu đường viền (xanh cyan mờ)
@export var circle_color: Color = Color(0.3, 0.8, 1.0, 0.3)

## Độ dày đường viền
@export var line_width: float = 2.0

## Reference đến MagnetArea để lấy radius
var magnet_shape: CircleShape2D = null


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Tìm MagnetArea sibling
	var magnet_area = get_parent().get_node_or_null("MagnetArea")
	if magnet_area:
		var collision = magnet_area.get_node_or_null("CollisionShape2D")
		if collision and collision.shape is CircleShape2D:
			magnet_shape = collision.shape


func _process(_delta: float) -> void:
	# Redraw mỗi frame để sync với radius thay đổi
	queue_redraw()


# ═══════════════════════════════════════════════════════════════════════════
#                              DRAWING
# ═══════════════════════════════════════════════════════════════════════════

func _draw() -> void:
	if not magnet_shape:
		return
	
	var radius = magnet_shape.radius
	
	# Vẽ đường tròn
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ draw_arc(center, radius, start_angle, end_angle, points, color)    │
	# │   - center: Vector2.ZERO = tâm tại vị trí node                     │
	# │   - TAU = 2π = 360 độ (full circle)                                 │
	# │   - 32 points = độ mượt của đường cong                              │
	# └─────────────────────────────────────────────────────────────────────┘
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, circle_color, line_width)
