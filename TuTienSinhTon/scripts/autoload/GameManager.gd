# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          GAME MANAGER                                     ║
# ║                    (Singleton - Autoload)                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC #1: Singleton Pattern là gì?                                    │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Singleton = Chỉ có 1 instance duy nhất trong toàn bộ game               │
# │                                                                         │
# │ GameManager là "bộ não" của game, điều phối mọi thứ:                    │
# │   - Game state (menu, playing, paused, game over)                       │
# │   - Thời gian trong run                                                 │
# │   - Điểm số, level, gold                                                │
# │   - Reference đến player                                                │
# │                                                                         │
# │ Vì là Autoload, bạn có thể gọi từ BẤT KỲ script nào:                   │
# │   GameManager.start_run()                                               │
# │   GameManager.current_time                                              │
# │   GameManager.player                                                    │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ "extends Node" nghĩa là script này KẾ THỪA từ class Node                │
# │ Node là class cơ bản nhất trong Godot, tồn tại trong scene tree         │
# └─────────────────────────────────────────────────────────────────────────┘


# ═══════════════════════════════════════════════════════════════════════════
#                              ENUMS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC #2: Enum là gì?                                                 │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Enum = Enumeration = Danh sách các giá trị cố định                      │
# │                                                                         │
# │ Thay vì dùng string "playing" hoặc số 1, ta dùng:                       │
# │   GameState.PLAYING                                                     │
# │                                                                         │
# │ LỢI ÍCH:                                                                │
# │   - Không sai chính tả (IDE báo lỗi nếu viết sai)                       │
# │   - Autocomplete (gõ GameState. sẽ hiện danh sách)                      │
# │   - Dễ đọc, dễ hiểu                                                     │
# └─────────────────────────────────────────────────────────────────────────┘

enum GameState {
	MENU,       # Đang ở menu chính
	PLAYING,    # Đang chơi run
	PAUSED,     # Đang pause
	LEVEL_UP,   # Đang chọn level up
	GAME_OVER,  # Run kết thúc
	VICTORY     # Sống sót 30 phút!
}


# ═══════════════════════════════════════════════════════════════════════════
#                              CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC #3: Constants (Hằng số)                                         │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ const = Giá trị KHÔNG BAO GIỜ THAY ĐỔI trong runtime                    │
# │                                                                         │
# │ VIẾT HOA_VỚI_UNDERSCORE là convention cho constants                     │
# │                                                                         │
# │ Tại sao dùng constants?                                                 │
# │   - Dễ điều chỉnh (chỉ sửa 1 chỗ)                                       │
# │   - Tránh "magic numbers" (số không rõ nghĩa trong code)                │
# │   - Self-documenting (tên constant giải thích ý nghĩa)                  │
# └─────────────────────────────────────────────────────────────────────────┘

const RUN_DURATION: float = 30.0 * 60.0  # 30 phút = 1800 giây
const BOSS_TIMES: Array[float] = [10.0 * 60, 12.0 * 60, 15.0 * 60, 20.0 * 60, 25.0 * 60]
# ↑ Boss xuất hiện ở phút 10, 12, 15, 20, 25


# ═══════════════════════════════════════════════════════════════════════════
#                              VARIABLES
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC #4: Variables và Type Hints                                    │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ GDScript là dynamically typed (không bắt buộc khai báo type)            │
# │ NHƯNG nên dùng Type Hints để:                                           │
# │   - IDE báo lỗi sớm                                                     │
# │   - Autocomplete tốt hơn                                                │
# │   - Code dễ đọc, dễ maintain                                            │
# │                                                                         │
# │ CÚ PHÁP: var tên: KiểuDữLiệu = giá_trị_mặc_định                        │
# │                                                                         │
# │ VÍ DỤ:                                                                  │
# │   var score: int = 0        # Số nguyên                                 │
# │   var name: String = ""     # Chuỗi                                     │
# │   var speed: float = 1.5    # Số thực                                   │
# │   var is_dead: bool = false # Boolean (true/false)                      │
# └─────────────────────────────────────────────────────────────────────────┘

# --- Game State ---
var current_state: GameState = GameState.MENU
# ↑ Trạng thái hiện tại của game

# --- Run Data (reset mỗi run mới) ---
var current_time: float = 0.0          # Thời gian đã chơi trong run (giây)
var current_level: int = 1             # Level hiện tại của player
var current_xp: int = 0                # XP hiện tại
var xp_to_next_level: int = 10         # XP cần để level up
var enemies_killed: int = 0            # Số enemy đã giết
var gold_collected: int = 0            # Gold thu được trong run này

# --- References ---
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC #5: Node References                                             │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Trong Godot, các object (Node) cần "biết" về nhau để tương tác          │
# │                                                                         │
# │ player: Player → biến này sẽ chứa reference đến Player node             │
# │ Khi Player được tạo, nó sẽ gọi:                                         │
# │   GameManager.player = self                                             │
# │                                                                         │
# │ Sau đó enemy có thể tìm player bằng:                                    │
# │   var target = GameManager.player.global_position                       │
# └─────────────────────────────────────────────────────────────────────────┘
var player: Node2D = null              # Reference đến Player node
var main_scene: Node = null            # Reference đến Main scene


# ═══════════════════════════════════════════════════════════════════════════
#                           LIFECYCLE METHODS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC #6: Godot Lifecycle (Vòng đời của Node)                         │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Godot gọi các hàm đặc biệt ở các thời điểm nhất định:                   │
# │                                                                         │
# │ _ready()         → Khi node VÀ tất cả children đã sẵn sàng              │
# │ _process(delta)  → Mỗi frame (60 lần/giây nếu 60 FPS)                   │
# │ _physics_process(delta) → Mỗi physics frame (mặc định 60/giây)          │
# │ _input(event)    → Khi có input event (phím, chuột)                     │
# │ _exit_tree()     → Khi node bị xóa khỏi scene tree                      │
# │                                                                         │
# │ delta = Thời gian giữa frame hiện tại và frame trước (giây)             │
# │ VD: 60 FPS → delta ≈ 0.0167 giây                                        │
# │                                                                         │
# │ TẠI SAO dùng delta?                                                     │
# │   Để game chạy CÙNG TỐC ĐỘ trên mọi máy tính                           │
# │   Di chuyển = speed * delta (không phụ thuộc FPS)                       │
# └─────────────────────────────────────────────────────────────────────────┘

func _ready() -> void:
	# Hàm này chạy 1 lần khi GameManager được load
	print("=== Tu Tiên Sinh Tồn ===")
	print("GameManager initialized!")
	# ↑ print() giúp debug, output hiện trong Godot Output panel


func _process(delta: float) -> void:
	# Hàm này chạy MỖI FRAME
	# Chỉ cập nhật timer khi đang chơi
	if current_state == GameState.PLAYING:
		_update_run_timer(delta)


# ═══════════════════════════════════════════════════════════════════════════
#                           PUBLIC METHODS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC #7: Public vs Private Methods                                  │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Trong GDScript:                                                         │
# │   - Hàm bắt đầu bằng _ (underscore) = Private (nội bộ)                  │
# │   - Hàm không có underscore = Public (gọi từ bên ngoài)                 │
# │                                                                         │
# │ VÍ DỤ:                                                                  │
# │   start_run() → Public, gọi từ UI button                                │
# │   _update_run_timer() → Private, chỉ dùng trong class này               │
# │                                                                         │
# │ Đây chỉ là CONVENTION (quy ước), GDScript không enforce                 │
# └─────────────────────────────────────────────────────────────────────────┘

## Bắt đầu một run mới
## Gọi khi player nhấn "Start Game"
func start_run() -> void:
	print("Starting new run...")
	
	# Reset tất cả data của run cũ
	_reset_run_data()
	
	# Đổi state sang PLAYING
	current_state = GameState.PLAYING
	
	# Phát signal để các hệ thống khác biết
	Events.run_started.emit()


## Kết thúc run (chết hoặc hết giờ)
## is_victory: true nếu sống sót 30 phút
func end_run(is_victory: bool) -> void:
	if is_victory:
		print("VICTORY! Độ Kiếp thành công!")
		current_state = GameState.VICTORY
	else:
		print("DEFEAT! Tu sĩ đã ngã xuống...")
		current_state = GameState.GAME_OVER
	
	# Phát signal
	Events.run_ended.emit(is_victory, gold_collected)


## Pause/Unpause game
func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		# ┌─────────────────────────────────────────────────────────────────┐
		# │ BÀI HỌC #8: get_tree() và pause                                 │
		# ├─────────────────────────────────────────────────────────────────┤
		# │ get_tree() trả về SceneTree - "cây" chứa tất cả nodes           │
		# │ get_tree().paused = true → Dừng tất cả nodes có pause_mode      │
		# │                                                                 │
		# │ Autoload (như GameManager) mặc định KHÔNG bị pause              │
		# │ → Vẫn xử lý được input khi game đang pause                      │
		# └─────────────────────────────────────────────────────────────────┘
		get_tree().paused = true
		Events.game_paused.emit()
		print("Game PAUSED")
	elif current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		Events.game_resumed.emit()
		print("Game RESUMED")


## Vào trạng thái level up (hiện UI chọn skill)
func enter_level_up() -> void:
	current_state = GameState.LEVEL_UP
	# UI sẽ handle pause/unpause
	Events.level_up_started.emit(current_level)


## Thoát trạng thái level up
func exit_level_up() -> void:
	current_state = GameState.PLAYING
	get_tree().paused = false
	Events.level_up_ended.emit()


## Thêm XP và check level up
func add_xp(amount: int) -> void:
	current_xp += amount
	Events.xp_changed.emit(current_xp, xp_to_next_level)
	
	# Check nếu đủ XP để level up
	while current_xp >= xp_to_next_level:
		_level_up()


## Thêm gold
func add_gold(amount: int) -> void:
	gold_collected += amount
	Events.gold_changed.emit(gold_collected)


## Đăng ký enemy bị giết
func register_enemy_kill() -> void:
	enemies_killed += 1
	Events.enemy_killed.emit(enemies_killed)


# ═══════════════════════════════════════════════════════════════════════════
#                           PRIVATE METHODS
# ═══════════════════════════════════════════════════════════════════════════

## Reset data khi bắt đầu run mới
func _reset_run_data() -> void:
	current_time = 0.0
	current_level = 1
	current_xp = 0
	xp_to_next_level = 10
	enemies_killed = 0
	gold_collected = 0


## Cập nhật timer của run
func _update_run_timer(delta: float) -> void:
	current_time += delta
	
	# Phát signal mỗi giây để update UI
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC #9: int() và fmod()                                         │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ int(x) = Chuyển x thành số nguyên (bỏ phần thập phân)               │
	# │ VD: int(3.7) = 3                                                    │
	# │                                                                     │
	# │ fmod(a, b) = Phần dư của a chia b (floating point modulo)           │
	# │ VD: fmod(5.5, 2.0) = 1.5                                            │
	# │                                                                     │
	# │ Logic ở đây: Chỉ emit signal khi GIÂY thay đổi                      │
	# │ (không emit 60 lần/giây vô nghĩa)                                   │
	# └─────────────────────────────────────────────────────────────────────┘
	var old_seconds: int = int(current_time - delta)
	var new_seconds: int = int(current_time)
	if new_seconds != old_seconds:
		Events.time_updated.emit(current_time)
	
	# Check hết giờ (Thiên Lôi!)
	if current_time >= RUN_DURATION:
		end_run(true)  # Victory!


## Xử lý level up
func _level_up() -> void:
	current_level += 1
	current_xp -= xp_to_next_level
	
	# Công thức XP cần cho level tiếp theo
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC #10: Công thức XP                                           │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ XP scaling phải "feel right":                                       │
	# │   - Quá dễ → Không có challenge                                     │
	# │   - Quá khó → Frustrating                                           │
	# │                                                                     │
	# │ Công thức đơn giản: base + (level * multiplier)                     │
	# │ Level 1→2: 10 XP                                                    │
	# │ Level 2→3: 10 + 2*5 = 20 XP                                         │
	# │ Level 3→4: 10 + 3*5 = 25 XP                                         │
	# │ ...                                                                 │
	# │                                                                     │
	# │ Sau này có thể điều chỉnh dựa trên playtesting!                     │
	# └─────────────────────────────────────────────────────────────────────┘
	xp_to_next_level = 10 + (current_level * 5)
	
	print("LEVEL UP! Now level ", current_level)
	
	# Vào trạng thái chọn skill
	enter_level_up()


# ═══════════════════════════════════════════════════════════════════════════
#                           HELPER METHODS
# ═══════════════════════════════════════════════════════════════════════════

## Lấy thời gian còn lại (giây)
func get_time_remaining() -> float:
	return max(0.0, RUN_DURATION - current_time)


## Lấy thời gian đã chơi dạng "MM:SS"
func get_time_string() -> String:
	var minutes: int = int(current_time) / 60
	var seconds: int = int(current_time) % 60
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC #11: String formatting                                      │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ "%02d" = Format số nguyên với ít nhất 2 chữ số, thêm 0 ở đầu        │
	# │ VD: 5 → "05", 12 → "12"                                             │
	# │                                                                     │
	# │ Kết quả: "05:30" thay vì "5:30"                                     │
	# └─────────────────────────────────────────────────────────────────────┘
	return "%02d:%02d" % [minutes, seconds]


## Check xem có đang trong run không
func is_run_active() -> bool:
	return current_state == GameState.PLAYING or current_state == GameState.LEVEL_UP
