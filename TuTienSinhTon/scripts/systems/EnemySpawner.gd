# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          ENEMY SPAWNER                                    ║
# ║                    Hệ Thống Spawn Yêu Ma                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Spawner Pattern                                                │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Spawner = Object chịu trách nhiệm TẠO enemies                           │
# │                                                                         │
# │ Tại sao cần Spawner riêng?                                              │
# │   - Tách biệt spawn logic khỏi enemy code                               │
# │   - Dễ điều chỉnh spawn rate, patterns                                  │
# │   - Dễ implement wave system, boss spawns                               │
# │   - Tập trung quản lý enemy count                                       │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node2D
class_name EnemySpawner


# ═══════════════════════════════════════════════════════════════════════════
#                              EXPORTS
# ═══════════════════════════════════════════════════════════════════════════

@export_group("Spawn Settings")
@export var spawn_radius_min: float = 400.0 # Khoảng cách tối thiểu spawn từ player
@export var spawn_radius_max: float = 600.0 # Khoảng cách tối đa
@export var max_enemies_on_screen: int = 200 # Giới hạn để tối ưu performance


# ═══════════════════════════════════════════════════════════════════════════
#                           PRELOADED SCENES
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Preload tất cả enemy scenes để spawn nhanh                              │
# │ (Load 1 lần, instantiate nhiều lần)                                     │
# └─────────────────────────────────────────────────────────────────────────┘

const ENEMY_SCENES = {
	"tieu_yeu_trung": preload("res://scenes/enemies/TieuYeuTrung.tscn"),
	"cuong_thi": preload("res://scenes/enemies/CuongThi.tscn"),
	"oan_hon": preload("res://scenes/enemies/OanHon.tscn"),
	"yeu_lang": preload("res://scenes/enemies/YeuLang.tscn"),
	"bach_cot_tinh": preload("res://scenes/enemies/BachCotTinh.tscn"),
}


# ═══════════════════════════════════════════════════════════════════════════
#                           SPAWN CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Spawn rate và enemy types thay đổi theo thời gian                       │
# │                                                                         │
# │ Format: {                                                               │
# │   "time_start": {                                                       │
# │       "spawn_rate": enemies/second,                                     │
# │       "enemies": ["enemy_id", weight]                                   │
# │   }                                                                     │
# │ }                                                                       │
# └─────────────────────────────────────────────────────────────────────────┘

var spawn_waves = {
	# Phase 1: 0:00 - 3:00 (TieuYeuTrung only)
	0: {
		"spawn_rate": 1.0,
		"enemies": [
			["tieu_yeu_trung", 100],
		]
	},
	60: { # 1:00
		"spawn_rate": 1.3,
		"enemies": [
			["tieu_yeu_trung", 100],
		]
	},
	
	# Phase 2: 3:00 - 5:00 (+ CuongThi)
	180: { # 3:00
		"spawn_rate": 1.5,
		"enemies": [
			["tieu_yeu_trung", 70],
			["cuong_thi", 30],
		]
	},
	240: { # 4:00
		"spawn_rate": 1.8,
		"enemies": [
			["tieu_yeu_trung", 60],
			["cuong_thi", 40],
		]
	},
	
	# Phase 3: 5:00 - 10:00 (+ OanHon, + YeuLang elite)
	300: { # 5:00
		"spawn_rate": 2.0,
		"enemies": [
			["tieu_yeu_trung", 50],
			["cuong_thi", 25],
			["oan_hon", 20],
			["yeu_lang", 5],
		]
	},
	420: { # 7:00
		"spawn_rate": 2.5,
		"enemies": [
			["tieu_yeu_trung", 40],
			["cuong_thi", 25],
			["oan_hon", 25],
			["yeu_lang", 10],
		]
	},
	
	# Phase 4: 10:00 - 15:00 (+ BachCotTinh boss)
	600: { # 10:00
		"spawn_rate": 3.0,
		"enemies": [
			["tieu_yeu_trung", 35],
			["cuong_thi", 20],
			["oan_hon", 25],
			["yeu_lang", 15],
			["bach_cot_tinh", 5],
		]
	},
	780: { # 13:00
		"spawn_rate": 3.5,
		"enemies": [
			["tieu_yeu_trung", 30],
			["cuong_thi", 20],
			["oan_hon", 25],
			["yeu_lang", 18],
			["bach_cot_tinh", 7],
		]
	},
	
	# Phase 5: 15:00 - 20:00 (Intense)
	900: { # 15:00
		"spawn_rate": 4.0,
		"enemies": [
			["tieu_yeu_trung", 25],
			["cuong_thi", 20],
			["oan_hon", 25],
			["yeu_lang", 20],
			["bach_cot_tinh", 10],
		]
	},
	
	# Phase 6: 20:00+ (Maximum chaos)
	1200: { # 20:00
		"spawn_rate": 5.0,
		"enemies": [
			["tieu_yeu_trung", 20],
			["cuong_thi", 20],
			["oan_hon", 25],
			["yeu_lang", 22],
			["bach_cot_tinh", 13],
		]
	},
}


# ═══════════════════════════════════════════════════════════════════════════
#                           INTERNAL STATE
# ═══════════════════════════════════════════════════════════════════════════

var current_spawn_rate: float = 1.0
var current_enemy_pool: Array = []
var spawn_timer: float = 0.0
var current_enemy_count: int = 0


# ═══════════════════════════════════════════════════════════════════════════
#                           LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_update_spawn_config(0)
	
	# Connect để update config khi thời gian thay đổi
	Events.time_updated.connect(_on_time_updated)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Spawn timer
	spawn_timer -= delta
	if spawn_timer <= 0:
		_try_spawn_enemy()
		spawn_timer = 1.0 / current_spawn_rate # Reset timer


# ═══════════════════════════════════════════════════════════════════════════
#                           SPAWNING
# ═══════════════════════════════════════════════════════════════════════════

func _try_spawn_enemy() -> void:
	# Check limit
	if current_enemy_count >= max_enemies_on_screen:
		return
	
	if not GameManager.player:
		return
	
	# Chọn enemy type ngẫu nhiên theo weight
	var enemy_id = _get_random_enemy_from_pool()
	if enemy_id.is_empty():
		return
	
	# Spawn!
	_spawn_enemy(enemy_id)


func _spawn_enemy(enemy_id: String) -> void:
	var enemy_scene = ENEMY_SCENES.get(enemy_id)
	if not enemy_scene:
		push_error("Enemy scene not found: " + enemy_id)
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Vị trí spawn: random position xung quanh player
	enemy.global_position = _get_spawn_position()
	
	# Track enemy death
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: tree_exiting signal                                        │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Mỗi Node có signal: tree_exiting                                    │
	# │ Phát ra TRƯỚC KHI node bị remove khỏi scene tree                    │
	# │                                                                     │
	# │ Perfect để track khi enemy bị destroy:                              │
	# │   enemy.tree_exiting.connect(_on_enemy_died)                        │
	# │                                                                     │
	# │ Khi enemy queue_free() → signal này phát → count giảm               │
	# └─────────────────────────────────────────────────────────────────────┘
	enemy.tree_exiting.connect(_on_enemy_died)
	
	# Add to scene
	add_child(enemy)
	current_enemy_count += 1


func _get_spawn_position() -> Vector2:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Random spawn position trong vòng tròn                      │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Để spawn enemy NGOÀI MÀN HÌNH nhưng gần player:                     │
	# │                                                                     │
	# │ 1. Chọn góc ngẫu nhiên: angle = random * 2π                         │
	# │ 2. Chọn khoảng cách: distance = random(min, max)                    │
	# │ 3. Tính position:                                                   │
	# │    x = player.x + cos(angle) * distance                             │
	# │    y = player.y + sin(angle) * distance                             │
	# │                                                                     │
	# │ Hoặc dùng Vector2.from_angle(angle) * distance                      │
	# └─────────────────────────────────────────────────────────────────────┘
	var player_pos = GameManager.player.global_position
	
	# Random angle (0 to 2π)
	var angle = randf() * TAU # TAU = 2π
	
	# Random distance trong khoảng min-max
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	
	# Tính offset position
	var offset = Vector2.from_angle(angle) * distance
	
	return player_pos + offset


func _get_random_enemy_from_pool() -> String:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Weighted Random Selection                                  │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Khi có nhiều enemy types với xác suất khác nhau:                    │
	# │                                                                     │
	# │ enemies = [["slime", 70], ["bat", 20], ["ghost", 10]]               │
	# │ → slime: 70% chance, bat: 20%, ghost: 10%                           │
	# │                                                                     │
	# │ ALGORITHM:                                                          │
	# │ 1. Tính tổng weight: 70 + 20 + 10 = 100                             │
	# │ 2. Random 0-100: ví dụ = 85                                         │
	# │ 3. Lặp qua list, cộng dồn weight:                                   │
	# │    - slime: 0+70 = 70 (85 > 70, tiếp tục)                           │
	# │    - bat: 70+20 = 90 (85 < 90, CHỌN bat!)                           │
	# │                                                                     │
	# │ Công thức này LUÔN đúng với bất kỳ weights nào                      │
	# └─────────────────────────────────────────────────────────────────────┘
	if current_enemy_pool.is_empty():
		return ""
	
	# Tính tổng weight
	var total_weight = 0
	for entry in current_enemy_pool:
		total_weight += entry[1]
	
	# Random
	var roll = randi() % total_weight
	
	# Tìm enemy
	var cumulative = 0
	for entry in current_enemy_pool:
		cumulative += entry[1]
		if roll < cumulative:
			return entry[0]
	
	# Fallback
	return current_enemy_pool[0][0]


# ═══════════════════════════════════════════════════════════════════════════
#                           EVENT HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_time_updated(current_time: float) -> void:
	# Check nếu cần update spawn config
	var time_seconds = int(current_time)
	
	# Tìm wave config phù hợp nhất
	var best_wave_time = 0
	for wave_time in spawn_waves.keys():
		if wave_time <= time_seconds and wave_time > best_wave_time:
			best_wave_time = wave_time
	
	_update_spawn_config(best_wave_time)


func _update_spawn_config(wave_time: int) -> void:
	var config = spawn_waves.get(wave_time)
	if config:
		current_spawn_rate = config.get("spawn_rate", 1.0)
		current_enemy_pool = config.get("enemies", [])


func _on_enemy_died() -> void:
	current_enemy_count -= 1
	current_enemy_count = max(0, current_enemy_count)
