# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          GACHA SELECTOR                                   ║
# ║              Module chọn ngẫu nhiên với animation nhấp nháy               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Module Pattern và Tái Sử Dụng Code                             │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ MODULE LÀ GÌ?                                                           │
# │   - Một đoạn code độc lập, có thể dùng lại nhiều nơi                    │
# │   - Giống như LEGO block - xây một lần, dùng nhiều lần                  │
# │   - VD: GachaSelector có thể dùng cho Level Up, mở rương, quay số...    │
# │                                                                         │
# │ TẠI SAO CẦN MODULE?                                                     │
# │   - DRY: Don't Repeat Yourself (Không lặp lại code)                     │
# │   - Dễ sửa: Sửa 1 nơi, tất cả nơi dùng đều update                       │
# │   - Dễ test: Module nhỏ, dễ test riêng lẻ                               │
# │                                                                         │
# │ CÁCH DÙNG MODULE NÀY:                                                   │
# │   1. var gacha = GachaSelector.new()                                    │
# │   2. add_child(gacha)  # Thêm vào scene tree                            │
# │   3. gacha.selection_finished.connect(callback)  # Nhận kết quả         │
# │   4. gacha.start([button1, button2, button3])  # Chạy!                  │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node
class_name GachaSelector
# ↑ class_name đăng ký class này globally
#   Sau khi save file, Godot tự biết "GachaSelector" là gì
#   Không cần preload() hay load() khi sử dụng


# ═══════════════════════════════════════════════════════════════════════════
#                              SIGNALS
# ═══════════════════════════════════════════════════════════════════════════
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Signal Pattern (Observer Pattern)                             │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ SIGNAL LÀ GÌ?                                                           │
# │   - Cách để object "la lên" khi có sự kiện xảy ra                       │
# │   - Ai quan tâm thì "đăng ký nghe" (connect)                            │
# │   - VD: Khi gacha xong, phát signal → LevelUpUI nghe và xử lý           │
# │                                                                         │
# │ TẠI SAO DÙNG SIGNAL THAY VÌ GỌI TRỰC TIẾP?                              │
# │   - Module không cần biết ai đang dùng nó                               │
# │   - Loose coupling: Dễ thay đổi, dễ mở rộng                             │
# │   - GachaSelector không cần biết LevelUpUI tồn tại                      │
# └─────────────────────────────────────────────────────────────────────────┘

## Phát ra khi animation bắt đầu
signal selection_started()

## Phát ra khi animation kết thúc, kèm index đã chọn
signal selection_finished(selected_index: int)


# ═══════════════════════════════════════════════════════════════════════════
#                              SETTINGS
# ═══════════════════════════════════════════════════════════════════════════
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: @export và Configuration                                      │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ @export LÀ GÌ?                                                          │
# │   - Biến có thể chỉnh trong Godot Editor (Inspector panel)              │
# │   - Không cần sửa code để thay đổi giá trị                              │
# │   - Designer có thể tweak mà không cần programmer                        │
# │                                                                         │
# │ GAME FEEL:                                                              │
# │   - Thời gian animation ảnh hưởng "cảm giác" khi chơi                   │
# │   - Quá nhanh: Không kịp nhìn, không hồi hộp                            │
# │   - Quá chậm: Nhàm chán, mất thời gian                                  │
# │   - 2-3 giây thường là "sweet spot" cho gacha                           │
# └─────────────────────────────────────────────────────────────────────────┘

## Tổng thời gian chạy animation (giây)
@export var total_duration: float = 2.5

## Tốc độ nhấp nháy ban đầu (giây giữa mỗi lần đổi)
## Nhỏ = nhanh, Lớn = chậm
@export var initial_speed: float = 0.06

## Tốc độ nhấp nháy cuối cùng (chậm dần rồi dừng)
@export var final_speed: float = 0.4

## Màu highlight khi đang chọn (nhấp nháy qua)
@export var highlight_color: Color = Color(1.5, 1.5, 0.5, 1)
# ↑ Color(1.5, ...) = sáng hơn bình thường (HDR color)
#   Giá trị > 1 tạo hiệu ứng "glow"

## Màu khi đã chọn xong (kết quả cuối)
@export var selected_color: Color = Color(0.3, 1.2, 0.3, 1)
# ↑ Xanh lá sáng = "thành công", quen thuộc với người chơi


# ═══════════════════════════════════════════════════════════════════════════
#                              STATE
# ═══════════════════════════════════════════════════════════════════════════
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: State Management                                              │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ STATE LÀ GÌ?                                                            │
# │   - Trạng thái hiện tại của object                                      │
# │   - VD: Đang chạy animation? Đang ở option nào? Đã chạy bao lâu?        │
# │                                                                         │
# │ TẠI SAO CẦN TRACK STATE?                                                │
# │   - _process() chạy mỗi frame (60 lần/giây)                             │
# │   - Cần biết "đang làm gì" để biết "làm gì tiếp"                        │
# │   - is_running = false → _process() không làm gì                        │
# │   - is_running = true → Chạy animation logic                            │
# └─────────────────────────────────────────────────────────────────────────┘

## Danh sách các Control nodes để highlight
var items: Array = []

## Animation có đang chạy không?
var is_running: bool = false

## Index đang được highlight hiện tại
var current_index: int = 0

## Index sẽ được chọn cuối cùng (biết trước từ đầu!)
var target_index: int = 0
# ↑ BÍ MẬT CỦA GACHA:
#   Kết quả được random NGAY TỪ ĐẦU
#   Animation chỉ là "diễn" cho hấp dẫn
#   Đây là cách hầu hết game làm!

## Thời gian đã trôi qua từ khi bắt đầu
var elapsed_time: float = 0.0

## Thời điểm chuyển sang option tiếp theo
var next_switch_time: float = 0.0

## Lưu màu gốc để restore sau khi xong
var original_colors: Array = []


# ═══════════════════════════════════════════════════════════════════════════
#                              PUBLIC METHODS
# ═══════════════════════════════════════════════════════════════════════════

## Bắt đầu gacha với danh sách items
## Parameters:
##   item_list: Array of Control nodes (buttons, panels, etc.)
##   preset_target: Nếu >= 0, sẽ dùng index này làm kết quả (cho testing)
## Returns: target_index (để biết trước kết quả nếu cần)
func start(item_list: Array, preset_target: int = -1) -> int:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Input Validation (Kiểm tra đầu vào)                        │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ LUÔN kiểm tra input trước khi xử lý!                                │
	# │   - Array rỗng? → Báo lỗi, return sớm                               │
	# │   - Đang chạy rồi? → Không cho chạy nữa                             │
	# │                                                                     │
	# │ "Garbage in, garbage out" - Input xấu = Output xấu                  │
	# └─────────────────────────────────────────────────────────────────────┘
	
	if item_list.is_empty():
		push_error("GachaSelector: item_list rỗng! Cần ít nhất 1 item.")
		return -1
	
	if is_running:
		push_warning("GachaSelector: Đang chạy rồi! Không thể start lại.")
		return target_index
	
	# Setup state
	items = item_list
	is_running = true
	elapsed_time = 0.0
	next_switch_time = 0.0
	current_index = 0
	
	# Random hoặc dùng preset
	if preset_target >= 0 and preset_target < items.size():
		target_index = preset_target
	else:
		target_index = randi() % items.size()
		# ↑ randi() = random integer
		#   % items.size() = đảm bảo trong range [0, size-1]
	
	# Lưu màu gốc để restore sau
	original_colors.clear()
	for item in items:
		if item and item is Control:
			original_colors.append(item.modulate)
		else:
			original_colors.append(Color.WHITE)
	
	# Phát signal bắt đầu
	selection_started.emit()
	
	return target_index


## Dừng animation và restore màu gốc
func stop() -> void:
	is_running = false
	_restore_colors()


# ═══════════════════════════════════════════════════════════════════════════
#                              PROCESS
# ═══════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: _process() và Frame-based Logic                            │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ _process(delta) được Godot gọi MỖI FRAME:                           │
	# │   - 60 FPS → gọi 60 lần/giây                                        │
	# │   - delta = thời gian từ frame trước (≈ 0.0167s ở 60FPS)            │
	# │                                                                     │
	# │ EARLY RETURN:                                                       │
	# │   - Nếu không cần xử lý gì, return ngay → Tiết kiệm CPU             │
	# │   - "if not is_running: return" = Không chạy thì không làm gì       │
	# └─────────────────────────────────────────────────────────────────────┘
	
	if not is_running:
		return
	
	# Cộng dồn thời gian
	elapsed_time += delta
	
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Easing (Làm mượt animation)                                │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ EASING LÀ GÌ?                                                       │
	# │   - Thay đổi tốc độ animation theo thời gian                        │
	# │   - Linear: Đều đặn (nhàm chán)                                     │
	# │   - Ease-out: Nhanh đầu, chậm cuối (tự nhiên hơn)                   │
	# │                                                                     │
	# │ GACHA DÙNG EASE-OUT:                                                │
	# │   - Bắt đầu: Nhấp nháy rất nhanh (hồi hộp!)                         │
	# │   - Dần dần: Chậm lại (căng thẳng!)                                 │
	# │   - Cuối: Gần như dừng hẳn (hồi hộp max!)                           │
	# │   - Dừng: Kết quả! (climax!)                                        │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Tính progress (0.0 → 1.0)
	var progress = clamp(elapsed_time / total_duration, 0.0, 1.0)
	
	# Áp dụng easing: ease-out cubic
	var eased_progress = _ease_out_cubic(progress)
	
	# Tính tốc độ hiện tại (interpolate giữa initial và final)
	var current_speed = lerp(initial_speed, final_speed, eased_progress)
	# ↑ lerp = Linear Interpolation
	#   lerp(a, b, t) = a + (b - a) * t
	#   t=0 → a, t=1 → b, t=0.5 → giữa a và b
	
	# Đến lúc chuyển sang item tiếp theo?
	if elapsed_time >= next_switch_time:
		next_switch_time = elapsed_time + current_speed
		_switch_to_next()
	
	# Animation kết thúc?
	if elapsed_time >= total_duration:
		_finish_selection()


func _switch_to_next() -> void:
	# Reset màu tất cả items về màu gốc
	_restore_colors()
	
	# Highlight item hiện tại
	if current_index >= 0 and current_index < items.size():
		var item = items[current_index]
		if item and item is Control:
			item.modulate = highlight_color
	
	# Chuyển sang item tiếp theo (vòng tròn)
	current_index = (current_index + 1) % items.size()
	# ↑ % = modulo, đảm bảo index luôn trong range
	#   VD: 3 items → index: 0, 1, 2, 0, 1, 2, ...


func _finish_selection() -> void:
	is_running = false
	
	# Reset tất cả về màu gốc
	_restore_colors()
	
	# Highlight KẾT QUẢ CUỐI CÙNG
	if target_index >= 0 and target_index < items.size():
		var item = items[target_index]
		if item and item is Control:
			item.modulate = selected_color
	
	# Phát signal kết thúc
	selection_finished.emit(target_index)


func _restore_colors() -> void:
	for i in range(items.size()):
		if i < original_colors.size() and items[i] and items[i] is Control:
			items[i].modulate = original_colors[i]


# ═══════════════════════════════════════════════════════════════════════════
#                              EASING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Công thức Easing                                               │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ EASE-OUT CUBIC: f(x) = 1 - (1-x)³                                       │
# │                                                                         │
# │   │    ___________                                                      │
# │ 1 │   /                                                                 │
# │   │  /                                                                  │
# │   │ /                                                                   │
# │ 0 │/___________                                                         │
# │   0            1                                                        │
# │                                                                         │
# │ Nhanh lúc đầu, chậm dần về cuối                                         │
# │ Dùng cho: Gacha, slide-in animation, deceleration                       │
# └─────────────────────────────────────────────────────────────────────────┘

func _ease_out_cubic(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)
