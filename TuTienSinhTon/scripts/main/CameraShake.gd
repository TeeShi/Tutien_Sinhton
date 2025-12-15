# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          CAMERA SHAKE                                     ║
# ║                  Screen shake effect cho game feel                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Screen Shake - "Game Juice" Quan Trọng                         │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ SCREEN SHAKE LÀM GÌ?                                                    │
# │   - Tạo cảm giác "impact" khi có sự kiện mạnh                           │
# │   - Player bị hit → màn hình rung → "Ow, that hurt!"                    │
# │   - Boss xuất hiện → màn hình rung → "Oh shit, he's big!"               │
# │                                                                         │
# │ NGUYÊN LÝ HOẠT ĐỘNG:                                                    │
# │   1. Khi trigger → set trauma = intensity                               │
# │   2. Mỗi frame → offset camera = random * trauma                        │
# │   3. Trauma giảm dần theo thời gian                                     │
# │   4. Trauma = 0 → camera trở về vị trí gốc                              │
# │                                                                         │
# │ TRAUMA SYSTEM (thay vì duration):                                       │
# │   - Trauma là "sức mạnh" của shake                                      │
# │   - Nhiều hit liên tiếp → trauma cộng dồn                               │
# │   - Tự nhiên hơn so với reset duration                                  │
# └─────────────────────────────────────────────────────────────────────────┘

extends Camera2D


# ═══════════════════════════════════════════════════════════════════════════
#                              SHAKE PARAMETERS
# ═══════════════════════════════════════════════════════════════════════════

## Độ mạnh tối đa của shake (pixels)
@export var max_offset: float = 8.0

## Góc xoay tối đa (degrees)
@export var max_rotation: float = 2.0

## Tốc độ giảm trauma (trauma/giây)
@export var trauma_decay: float = 2.0

## Tốc độ shake (frequency)
@export var shake_speed: float = 30.0


# ═══════════════════════════════════════════════════════════════════════════
#                              STATE
# ═══════════════════════════════════════════════════════════════════════════

var trauma: float = 0.0  # 0-1, mức độ "chấn thương" hiện tại
var noise_y: float = 0.0  # Offset cho noise sampling


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Connect signals từ Events
	Events.player_damaged.connect(_on_player_damaged)
	# Có thể thêm boss spawn signal sau
	
	print("CameraShake ready!")


# ═══════════════════════════════════════════════════════════════════════════
#                              PROCESS
# ═══════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	# Giảm trauma theo thời gian
	if trauma > 0:
		trauma = max(trauma - trauma_decay * delta, 0.0)
		_apply_shake()
	else:
		# Reset camera về vị trí gốc
		offset = Vector2.ZERO
		rotation = 0.0


func _apply_shake() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Trauma Squared                                             │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Dùng trauma² thay vì trauma:                                        │
	# │   - trauma = 0.5 → shake = 0.25 (nhẹ)                               │
	# │   - trauma = 1.0 → shake = 1.0 (mạnh)                               │
	# │                                                                     │
	# │ Kết quả: shake nhẹ khi trauma thấp, mạnh khi trauma cao             │
	# │ Cảm giác tự nhiên hơn                                               │
	# └─────────────────────────────────────────────────────────────────────┘
	var shake_amount = trauma * trauma
	
	# Random offset
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Perlin Noise vs Random                                     │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Random mỗi frame → jerky, không tự nhiên                            │
	# │ Perlin Noise → smooth transitions, organic feel                     │
	# │                                                                     │
	# │ Đơn giản: dùng randf_range với lerp để smooth hơn                   │
	# └─────────────────────────────────────────────────────────────────────┘
	
	noise_y += shake_speed * get_process_delta_time()
	
	# Offset XY
	offset.x = randf_range(-max_offset, max_offset) * shake_amount
	offset.y = randf_range(-max_offset, max_offset) * shake_amount
	
	# Rotation (nhẹ)
	rotation_degrees = randf_range(-max_rotation, max_rotation) * shake_amount


# ═══════════════════════════════════════════════════════════════════════════
#                           PUBLIC METHODS
# ═══════════════════════════════════════════════════════════════════════════

## Thêm trauma (gây shake)
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)  # Cap at 1.0


## Preset shakes
func shake_small() -> void:
	add_trauma(0.2)

func shake_medium() -> void:
	add_trauma(0.4)

func shake_large() -> void:
	add_trauma(0.7)

func shake_boss() -> void:
	add_trauma(1.0)


# ═══════════════════════════════════════════════════════════════════════════
#                           SIGNAL HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_player_damaged(_damage: int, _current_hp: int) -> void:
	shake_medium()
