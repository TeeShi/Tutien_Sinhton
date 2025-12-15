# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          CHARACTER DATA                                    ║
# ║              Resource chứa data của mỗi Tu Sĩ                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Godot Resource System                                          │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ RESOURCE LÀ GÌ?                                                         │
# │   Resource = Data container, lưu dữ liệu có thể được chia sẻ            │
# │   Ví dụ: Texture, AudioStream, Animation... đều là Resources            │
# │                                                                         │
# │ TẠI SAO TẠO CUSTOM RESOURCE?                                            │
# │   1. Data-Driven Design: Designer chỉnh data không cần code             │
# │   2. Inspector UI: Godot tự tạo form chỉnh sửa từ @export               │
# │   3. Hot-reload: Sửa .tres → game update ngay không cần restart         │
# │   4. Reusable: Dùng chung một resource ở nhiều nơi                      │
# │                                                                         │
# │ CÁCH TẠO:                                                               │
# │   1. Script extend Resource với class_name                              │
# │   2. Thêm @export variables                                             │
# │   3. Trong Editor: Right-click → New Resource → chọn class              │
# │   4. Fill data → Save as .tres                                          │
# │                                                                         │
# │ CÁCH DÙNG:                                                              │
# │   var data = load("res://data/character.tres") as CharacterData         │
# │   print(data.character_name)                                            │
# └─────────────────────────────────────────────────────────────────────────┘

extends Resource
class_name CharacterData


# ═══════════════════════════════════════════════════════════════════════════
#                              BASIC INFO
# ═══════════════════════════════════════════════════════════════════════════

@export var character_id: String = ""
@export var character_name: String = ""
@export var linh_can: String = ""  # Kim, Mộc, Thủy, Hỏa, Thổ
@export_multiline var lore: String = ""

# Unlock
@export var is_unlocked_by_default: bool = true
@export var unlock_condition: String = ""


# ═══════════════════════════════════════════════════════════════════════════
#                           STARTING WEAPON
# ═══════════════════════════════════════════════════════════════════════════

@export var starting_weapon_scene: PackedScene = null
@export var starting_weapon_id: String = ""


# ═══════════════════════════════════════════════════════════════════════════
#                           PASSIVE BONUSES
# ═══════════════════════════════════════════════════════════════════════════

@export_group("Passive Bonuses")
@export var bonus_damage: float = 0.0        # +X% damage
@export var bonus_area: float = 0.0          # +X% area
@export var bonus_cooldown: float = 0.0      # -X% cooldown (negative = faster)
@export var bonus_max_hp: float = 0.0        # +X% max HP
@export var bonus_recovery: float = 0.0      # +X HP/s
@export var bonus_speed: float = 0.0         # +X% move speed
@export var bonus_magnet: float = 0.0        # +X% magnet radius
@export var bonus_growth: float = 0.0        # +X% XP gain


# ═══════════════════════════════════════════════════════════════════════════
#                           PER-LEVEL SCALING
# ═══════════════════════════════════════════════════════════════════════════

@export_group("Per-Level Scaling")
@export var damage_per_level: float = 0.0
@export var area_per_level: float = 0.0
@export var cooldown_per_level: float = 0.0
@export var hp_per_level: float = 0.0
@export var recovery_per_level: float = 0.0


# ═══════════════════════════════════════════════════════════════════════════
#                              VISUALS
# ═══════════════════════════════════════════════════════════════════════════

@export_group("Visuals")
@export var sprite_color: Color = Color.WHITE
@export var icon: Texture2D = null


# ═══════════════════════════════════════════════════════════════════════════
#                              METHODS
# ═══════════════════════════════════════════════════════════════════════════

## Apply passive bonuses cho player dựa trên level
func apply_to_player(player: Node, level: int = 1) -> void:
	# Base bonuses
	if bonus_damage > 0:
		player.damage_multiplier *= (1.0 + bonus_damage + damage_per_level * (level - 1))
	
	if bonus_area > 0:
		player.area_multiplier *= (1.0 + bonus_area + area_per_level * (level - 1))
	
	if bonus_cooldown != 0:
		player.cooldown_multiplier *= (1.0 + bonus_cooldown + cooldown_per_level * (level - 1))
	
	if bonus_max_hp > 0:
		var bonus = int(player.max_hp * (bonus_max_hp + hp_per_level * (level - 1)))
		player.max_hp += bonus
		player.current_hp += bonus
	
	if bonus_recovery > 0:
		player.recovery += bonus_recovery + recovery_per_level * (level - 1)
	
	if bonus_speed > 0:
		player.base_move_speed *= (1.0 + bonus_speed)
	
	if bonus_magnet > 0 and player.has_node("MagnetArea/CollisionShape2D"):
		var shape = player.get_node("MagnetArea/CollisionShape2D").shape
		if shape is CircleShape2D:
			shape.radius *= (1.0 + bonus_magnet)
	
	if bonus_growth > 0:
		player.xp_multiplier *= (1.0 + bonus_growth)
	
	# Apply color
	if player.has_node("Sprite2D"):
		player.get_node("Sprite2D").modulate = sprite_color
	
	print("Applied character: ", character_name, " (Level ", level, ")")
