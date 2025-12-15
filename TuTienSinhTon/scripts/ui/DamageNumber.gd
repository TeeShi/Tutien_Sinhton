# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          DAMAGE NUMBER                                    ║
# ║               Fancy floating damage text với pop effect                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Damage Numbers - Visual Feedback                               │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ TẠI SAO CẦN DAMAGE NUMBERS?                                              │
# │   - Player biết damage đang gây ra                                       │
# │   - Thỏa mãn khi thấy số lớn                                            │
# │   - Giúp balance game (biết skill nào mạnh)                              │
# │                                                                         │
# │ "FANCY" DAMAGE NUMBERS:                                                  │
# │   1. Scale: Lớn → nhỏ dần (pop effect)                                  │
# │   2. Movement: Bay lên và fade out                                       │
# │   3. Color: Trắng bình thường, vàng/đỏ cho crit                          │
# │   4. Font: Bold, dễ đọc                                                  │
# │                                                                         │
# │ NGUYÊN LÝ: Số lớn = visual feedback mạnh hơn                             │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node2D


# ═══════════════════════════════════════════════════════════════════════════
#                              ANIMATION SETTINGS
# ═══════════════════════════════════════════════════════════════════════════

## Thời gian hiển thị (giây)
@export var lifetime: float = 0.8

## Tốc độ bay lên
@export var rise_speed: float = 50.0

## Độ giảm tốc bay lên
@export var rise_decel: float = 100.0

## Độ random offset X khi spawn
@export var spread_x: float = 20.0

## Scale bắt đầu (pop effect)
@export var start_scale: float = 1.5

## Scale kết thúc
@export var end_scale: float = 0.6

## Outline thickness
@export var outline_size: int = 4


# ═══════════════════════════════════════════════════════════════════════════
#                              COLORS
# ═══════════════════════════════════════════════════════════════════════════

const COLOR_NORMAL = Color(1.0, 1.0, 1.0)           # Trắng
const COLOR_CRIT = Color(1.0, 0.8, 0.0)             # Vàng gold
const COLOR_CRIT_STRONG = Color(1.0, 0.3, 0.1)      # Đỏ cam
const COLOR_HEAL = Color(0.3, 1.0, 0.3)             # Xanh lá
const OUTLINE_COLOR = Color(0.0, 0.0, 0.0, 0.8)     # Đen (outline)


# ═══════════════════════════════════════════════════════════════════════════
#                              STATE
# ═══════════════════════════════════════════════════════════════════════════

var damage_value: int = 0
var is_crit: bool = false
var is_heal: bool = false
var timer: float = 0.0
var velocity_y: float = 0.0
var label: Label = null


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Tạo Label node
	label = Label.new()
	add_child(label)
	
	# Settings cho Label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.pivot_offset = label.size / 2
	
	# Random X offset để numbers không chồng lên nhau
	position.x += randf_range(-spread_x, spread_x)
	
	# Initial scale (pop effect start)
	scale = Vector2(start_scale, start_scale)
	
	# Initial velocity
	velocity_y = -rise_speed


## Thiết lập damage number
func setup(value: int, crit: bool = false, heal: bool = false) -> void:
	damage_value = value
	is_crit = crit
	is_heal = heal
	
	# Set text
	if heal:
		label.text = "+%d" % value
	else:
		label.text = "%d" % value
	
	# Set color dựa trên type
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: LabelSettings                                              │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Label.add_theme_* = cách cũ (phức tạp)                              │
	# │ LabelSettings = cách mới (clean, dễ dùng)                           │
	# │                                                                     │
	# │ LabelSettings chứa:                                                 │
	# │   - font_size: cỡ chữ                                               │
	# │   - font_color: màu chữ                                             │
	# │   - outline_size: độ dày outline                                    │
	# │   - outline_color: màu outline                                      │
	# └─────────────────────────────────────────────────────────────────────┘
	var settings = LabelSettings.new()
	
	if heal:
		settings.font_color = COLOR_HEAL
		settings.font_size = 20
	elif crit:
		settings.font_color = COLOR_CRIT if value < 100 else COLOR_CRIT_STRONG
		settings.font_size = 28  # Crit lớn hơn
	else:
		settings.font_color = COLOR_NORMAL
		settings.font_size = 20
	
	settings.outline_size = outline_size
	settings.outline_color = OUTLINE_COLOR
	
	label.label_settings = settings
	
	# Crit có scale lớn hơn
	if crit:
		scale = Vector2(start_scale * 1.3, start_scale * 1.3)


# ═══════════════════════════════════════════════════════════════════════════
#                              PROCESS
# ═══════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	timer += delta
	
	# Progress từ 0 → 1
	var progress = timer / lifetime
	
	if progress >= 1.0:
		queue_free()
		return
	
	# Movement - bay lên và chậm dần
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Easing Functions                                           │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Linear: tiến đều từ đầu đến cuối                                    │
	# │ Ease Out: nhanh đầu, chậm cuối (tự nhiên hơn)                       │
	# │ Ease In: chậm đầu, nhanh cuối                                       │
	# │                                                                     │
	# │ Công thức Ease Out Quad: 1 - (1 - t)²                               │
	# └─────────────────────────────────────────────────────────────────────┘
	velocity_y = move_toward(velocity_y, 0, rise_decel * delta)
	position.y += velocity_y * delta
	
	# Scale - từ lớn → nhỏ (ease out)
	var scale_t = 1.0 - pow(1.0 - progress, 2)  # Ease out quad
	var current_scale = lerp(start_scale, end_scale, scale_t)
	scale = Vector2(current_scale, current_scale)
	
	# Fade out trong nửa cuối
	if progress > 0.5:
		var fade_progress = (progress - 0.5) / 0.5  # 0 → 1 trong nửa cuối
		modulate.a = 1.0 - fade_progress
