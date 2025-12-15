# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          META MANAGER                                      ║
# ║              Quản lý Meta Progression - Autoload Singleton                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ MetaManager lưu trữ data VĨNH VIỄN giữa các runs:                       │
# │   - Linh Thạch (Gold)                                                   │
# │   - PowerUp levels                                                       │
# │   - Unlocks                                                              │
# │   - Statistics                                                           │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node


# ═══════════════════════════════════════════════════════════════════════════
#                           CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════

const SAVE_PATH = "user://meta_data.json"


# ═══════════════════════════════════════════════════════════════════════════
#                           POWERUP DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════

const POWERUPS = {
	"might": {
		"name": "Lực",
		"description": "+5% Damage",
		"max_level": 5,
		"cost_per_level": 200,
		"effect_per_level": 0.05 # 5% damage
	},
	"max_hp": {
		"name": "Sinh Lực",
		"description": "+10% Max HP",
		"max_level": 3,
		"cost_per_level": 200,
		"effect_per_level": 0.10 # 10% HP
	},
	"move_speed": {
		"name": "Di Tốc",
		"description": "+5% Move Speed",
		"max_level": 2,
		"cost_per_level": 300,
		"effect_per_level": 0.05 # 5% speed
	},
	"magnet": {
		"name": "Hấp Thu",
		"description": "+25% Magnet Radius",
		"max_level": 2,
		"cost_per_level": 300,
		"effect_per_level": 0.25 # 25% radius
	},
	"growth": {
		"name": "Ngộ Đạo",
		"description": "+5% XP Gain",
		"max_level": 3,
		"cost_per_level": 300,
		"effect_per_level": 0.05 # 5% XP
	},
}


# ═══════════════════════════════════════════════════════════════════════════
#                           PLAYER DATA
# ═══════════════════════════════════════════════════════════════════════════

var gold: int = 0
var powerup_levels: Dictionary = {} # {"might": 2, "max_hp": 1, etc}

# Statistics
var total_runs: int = 0
var total_kills: int = 0
var total_gold_earned: int = 0
var best_time_survived: float = 0.0


# ═══════════════════════════════════════════════════════════════════════════
#                           LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Initialize powerup levels to 0
	for id in POWERUPS.keys():
		powerup_levels[id] = 0
	
	# Load saved data
	load_data()
	
	print("MetaManager ready! Gold: ", gold)


# ═══════════════════════════════════════════════════════════════════════════
#                           GOLD MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════

func add_gold(amount: int) -> void:
	gold += amount
	total_gold_earned += amount
	Events.gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		Events.gold_changed.emit(gold)
		return true
	return false


func get_gold() -> int:
	return gold


# ═══════════════════════════════════════════════════════════════════════════
#                           POWERUP MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════

func get_powerup_level(powerup_id: String) -> int:
	return powerup_levels.get(powerup_id, 0)


func get_powerup_cost(powerup_id: String) -> int:
	var data = POWERUPS.get(powerup_id)
	if not data:
		return 0
	return data["cost_per_level"]


func can_buy_powerup(powerup_id: String) -> bool:
	var data = POWERUPS.get(powerup_id)
	if not data:
		return false
	
	var current_level = powerup_levels.get(powerup_id, 0)
	if current_level >= data["max_level"]:
		return false # Already maxed
	
	return gold >= data["cost_per_level"]


func buy_powerup(powerup_id: String) -> bool:
	if not can_buy_powerup(powerup_id):
		return false
	
	var cost = get_powerup_cost(powerup_id)
	if spend_gold(cost):
		powerup_levels[powerup_id] = powerup_levels.get(powerup_id, 0) + 1
		save_data()
		print("Bought ", powerup_id, " level ", powerup_levels[powerup_id])
		return true
	return false


func refund_all() -> void:
	# Tính tổng gold đã chi
	var total_refund = 0
	for id in powerup_levels.keys():
		var level = powerup_levels[id]
		var cost = POWERUPS[id]["cost_per_level"]
		total_refund += level * cost
		powerup_levels[id] = 0
	
	gold += total_refund
	Events.gold_changed.emit(gold)
	save_data()
	print("Refunded ", total_refund, " gold!")


# ═══════════════════════════════════════════════════════════════════════════
#                           APPLY BUFFS
# ═══════════════════════════════════════════════════════════════════════════

## Gọi function này khi bắt đầu run để apply buffs
func apply_powerups_to_player(player: Node) -> void:
	# Might - Damage bonus
	var might_level = powerup_levels.get("might", 0)
	if might_level > 0:
		var bonus = might_level * POWERUPS["might"]["effect_per_level"]
		player.damage_multiplier = 1.0 + bonus
		print("Applied Might: +", bonus * 100, "% damage")
	
	# Max HP
	var hp_level = powerup_levels.get("max_hp", 0)
	if hp_level > 0:
		var bonus = hp_level * POWERUPS["max_hp"]["effect_per_level"]
		var extra_hp = int(player.max_hp * bonus)
		player.max_hp += extra_hp
		player.current_hp += extra_hp
		print("Applied Max HP: +", extra_hp)
	
	# Move Speed
	var speed_level = powerup_levels.get("move_speed", 0)
	if speed_level > 0:
		var bonus = speed_level * POWERUPS["move_speed"]["effect_per_level"]
		player.base_move_speed *= (1.0 + bonus)
		print("Applied Move Speed: +", bonus * 100, "%")
	
	# Magnet
	var magnet_level = powerup_levels.get("magnet", 0)
	if magnet_level > 0 and player.has_node("MagnetArea/CollisionShape2D"):
		var bonus = magnet_level * POWERUPS["magnet"]["effect_per_level"]
		var shape = player.get_node("MagnetArea/CollisionShape2D").shape
		if shape is CircleShape2D:
			shape.radius *= (1.0 + bonus)
			print("Applied Magnet: +", bonus * 100, "% radius")
	
	# Growth (XP) - Lưu multiplier để dùng sau
	var growth_level = powerup_levels.get("growth", 0)
	if growth_level > 0:
		var bonus = growth_level * POWERUPS["growth"]["effect_per_level"]
		player.xp_multiplier = 1.0 + bonus
		print("Applied Growth: +", bonus * 100, "% XP")


# ═══════════════════════════════════════════════════════════════════════════
#                           SAVE / LOAD
# ═══════════════════════════════════════════════════════════════════════════

func save_data() -> void:
	var data = {
		"gold": gold,
		"powerup_levels": powerup_levels,
		"total_runs": total_runs,
		"total_kills": total_kills,
		"total_gold_earned": total_gold_earned,
		"best_time_survived": best_time_survived,
	}
	
	var json_string = JSON.stringify(data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Meta data saved!")


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found, using defaults")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse save file")
		return
	
	var data = json.get_data()
	
	gold = data.get("gold", 0)
	
	# Load powerup levels
	var saved_levels = data.get("powerup_levels", {})
	for id in saved_levels.keys():
		powerup_levels[id] = saved_levels[id]
	
	total_runs = data.get("total_runs", 0)
	total_kills = data.get("total_kills", 0)
	total_gold_earned = data.get("total_gold_earned", 0)
	best_time_survived = data.get("best_time_survived", 0.0)
	
	print("Meta data loaded! Gold: ", gold)


# ═══════════════════════════════════════════════════════════════════════════
#                           RUN TRACKING
# ═══════════════════════════════════════════════════════════════════════════

func on_run_started() -> void:
	total_runs += 1


func on_run_ended(time_survived: float, kills: int, gold_collected: int) -> void:
	total_kills += kills
	add_gold(gold_collected)
	
	if time_survived > best_time_survived:
		best_time_survived = time_survived
	
	save_data()
