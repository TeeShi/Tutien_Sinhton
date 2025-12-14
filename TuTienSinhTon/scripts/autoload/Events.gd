# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          EVENTS (Signal Bus)                              ║
# ║                    (Singleton - Autoload)                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Signal Bus Pattern                                             │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ SIGNAL là gì?                                                           │
# │   - Cách để objects "nói chuyện" với nhau mà không cần biết nhau        │
# │   - Giống như radio broadcast: phát ra, ai quan tâm thì nghe            │
# │                                                                         │
# │ VẤN ĐỀ:                                                                 │
# │   Player cần nói với UI rằng HP thay đổi                                │
# │   Nhưng Player không nên "biết" về UI (coupling chặt = bad)             │
# │                                                                         │
# │ GIẢI PHÁP - Signal Bus:                                                 │
# │   1. Tạo 1 nơi TRUNG TÂM chứa tất cả signals (Events autoload)          │
# │   2. Ai muốn PHÁT signal: Events.signal_name.emit()                     │
# │   3. Ai muốn NGHE signal: Events.signal_name.connect(my_function)       │
# │                                                                         │
# │ VÍ DỤ:                                                                  │
# │   Player bị hit:                                                        │
# │     Events.player_health_changed.emit(new_hp, max_hp)                   │
# │                                                                         │
# │   UI đã connect từ trước:                                               │
# │     Events.player_health_changed.connect(_on_health_changed)            │
# │                                                                         │
# │   → UI tự động update, Player không cần biết UI tồn tại!                │
# │                                                                         │
# │ LỢI ÍCH:                                                                │
# │   - Loose coupling (các class độc lập)                                  │
# │   - Dễ thêm/bớt listeners                                               │
# │   - Dễ debug (tất cả events ở 1 chỗ)                                    │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node


# ═══════════════════════════════════════════════════════════════════════════
#                              SIGNALS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Khai báo Signal                                                │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ CÚ PHÁP:                                                                │
# │   signal tên_signal                           # Không có tham số        │
# │   signal tên_signal(param1: Type)             # Có 1 tham số            │
# │   signal tên_signal(param1: Type, param2: Type) # Có nhiều tham số      │
# │                                                                         │
# │ CÁCH PHÁT (emit):                                                       │
# │   Events.tên_signal.emit()                    # Không tham số           │
# │   Events.tên_signal.emit(value)               # Có tham số              │
# │                                                                         │
# │ CÁCH NGHE (connect):                                                    │
# │   Events.tên_signal.connect(_my_handler)      # Connect đến hàm         │
# │                                                                         │
# │ HÀM HANDLER phải có CÙNG SỐ THAM SỐ với signal!                        │
# └─────────────────────────────────────────────────────────────────────────┘

# --- Game State Signals ---
signal run_started                                 # Run mới bắt đầu
signal run_ended(is_victory: bool, gold: int)      # Run kết thúc
signal game_paused                                 # Game pause
signal game_resumed                                # Game resume từ pause
signal victory                                     # Sống sót đủ 30 phút!

# --- Time Signals ---
signal time_updated(current_time: float)           # Mỗi giây trong run

# --- Player Signals ---
signal player_spawned(player: Node2D)              # Player được tạo
signal player_health_changed(current: int, max: int) # HP thay đổi
signal player_died                                 # Player chết

# --- XP & Level Signals ---
signal xp_changed(current_xp: int, xp_needed: int) # XP thay đổi
signal xp_gem_collected(value: int)                # Nhặt được XP gem
signal level_up_started(new_level: int)            # Bắt đầu chọn skill
signal level_up_ended                              # Xong chọn skill

# --- Combat Signals ---
signal enemy_killed(total_kills: int)              # Enemy bị giết
signal enemy_spawned(enemy: Node2D)                # Enemy spawn
signal damage_dealt(amount: int, position: Vector2) # Gây damage (cho damage numbers)
signal boss_spawned(boss: Node2D)                  # Boss xuất hiện

# --- Weapon Signals ---
signal weapon_acquired(weapon_id: String)          # Có weapon mới
signal weapon_upgraded(weapon_id: String, level: int) # Upgrade weapon

# --- Passive Signals ---
signal passive_acquired(passive_id: String)        # Có passive mới
signal passive_upgraded(passive_id: String, level: int) # Upgrade passive

# --- Evolution Signals ---
signal evolution_ready(evolved_weapon_id: String)  # Có thể evolve
signal evolution_triggered(evolved_weapon_id: String) # Đã evolve

# --- Pickup Signals ---
signal gold_changed(total_gold: int)               # Gold thay đổi
signal chest_opened                                # Mở treasure chest

# --- UI Signals ---
signal show_damage_number(damage: int, position: Vector2, is_crit: bool)


# ═══════════════════════════════════════════════════════════════════════════
#                           HELPER METHODS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Các hàm helper để debug hoặc thống kê                                   │
# └─────────────────────────────────────────────────────────────────────────┘

func _ready() -> void:
	print("Events Signal Bus initialized!")
	# Có thể connect debug handlers ở đây nếu cần
	# VD: run_started.connect(_debug_run_started)


# Debug: Log khi run bắt đầu
func _debug_run_started() -> void:
	print("[DEBUG] Run started!")
