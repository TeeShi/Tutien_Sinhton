# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          BASE WEAPON                                      ║
# ║              Công Pháp Cơ Bản - Abstract Base Class                       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Inheritance (Kế thừa) và Abstract Class                        │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ INHERITANCE là gì?                                                      │
# │   - Class con KẾ THỪA thuộc tính và hành vi từ class cha                │
# │   - VD: PhiKiem extends BaseWeapon                                      │
# │   - PhiKiem có TẤT CẢ functions của BaseWeapon + thêm riêng             │
# │                                                                         │
# │ ABSTRACT CLASS là gì?                                                   │
# │   - Class "bản mẫu", KHÔNG dùng trực tiếp                               │
# │   - Chỉ dùng để các class khác kế thừa                                  │
# │   - GDScript không có từ khóa "abstract", ta tự convention              │
# │                                                                         │
# │ TẠI SAO cần BaseWeapon?                                                 │
# │   - Tất cả weapons có điểm CHUNG: cooldown, damage, level               │
# │   - Viết 1 lần ở đây, tất cả weapons khác tự có                         │
# │   - Dễ thêm weapon mới (chỉ cần override _attack())                     │
# │                                                                         │
# │ HIERARCHY:                                                              │
# │   BaseWeapon (abstract)                                                 │
# │   ├── PhiKiem (Flying Sword)                                            │
# │   ├── HoaCau (Fireball)                                                 │
# │   ├── LoiKich (Thunder Strike)                                          │
# │   └── ... (tất cả weapons khác)                                         │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node2D
class_name BaseWeapon


# ═══════════════════════════════════════════════════════════════════════════
#                              EXPORTS
# ═══════════════════════════════════════════════════════════════════════════

@export_group("Weapon Info")
@export var weapon_id: String = "base_weapon"   # ID duy nhất
@export var weapon_name: String = "Base Weapon" # Tên hiển thị
@export_multiline var description: String = ""  # Mô tả

@export_group("Base Stats - Level 1")
@export var base_damage: float = 10.0           # Damage cơ bản
@export var base_cooldown: float = 1.0          # Giây giữa các lần attack
@export var base_area: float = 1.0              # Kích thước AoE (multiplier)
@export var base_speed: float = 200.0           # Tốc độ projectile
@export var base_duration: float = 1.0          # Thời gian tồn tại
@export var base_amount: int = 1                # Số projectile
@export var base_pierce: int = 1                # Số enemy có thể xuyên qua
@export var base_knockback: float = 0.0         # Đẩy lùi enemy

@export_group("Upgrade Bonuses")
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Array chứa bonus cho mỗi level (index 0 = level 2, vì level 1 = base)   │
# │ Format: { "stat": "bonus_value" }                                       │
# │ VD: Level 2 thêm 20% damage, Level 3 thêm 1 projectile                  │
# └─────────────────────────────────────────────────────────────────────────┘
@export var max_level: int = 8
# Upgrades sẽ được define trong class con


# ═══════════════════════════════════════════════════════════════════════════
#                           CURRENT STATS
# ═══════════════════════════════════════════════════════════════════════════

var current_level: int = 1
var current_damage: float = 10.0
var current_cooldown: float = 1.0
var current_area: float = 1.0
var current_speed: float = 200.0
var current_duration: float = 1.0
var current_amount: int = 1
var current_pierce: int = 1
var current_knockback: float = 0.0


# ═══════════════════════════════════════════════════════════════════════════
#                           INTERNAL STATE
# ═══════════════════════════════════════════════════════════════════════════

var cooldown_timer: float = 0.0  # Countdown đến lần attack tiếp
var can_attack: bool = true      # Có thể attack không?
var player: Player = null        # Reference đến player


# ═══════════════════════════════════════════════════════════════════════════
#                           LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: get_parent() và Type Casting                              │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ get_parent() trả về Node cha trong scene tree                       │
	# │                                                                     │
	# │ Weapons nằm trong: Player → WeaponContainer → Weapon                │
	# │ Nên get_parent().get_parent() = Player                              │
	# │                                                                     │
	# │ "as Player" = Type casting, nói cho Godot biết đây là Player        │
	# │ → Có autocomplete và type checking                                  │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Tìm player (weapon là child của WeaponContainer, là child của Player)
	var weapon_container = get_parent()
	if weapon_container:
		player = weapon_container.get_parent() as Player
	
	# Initialize stats
	recalculate_stats()
	
	print(weapon_name, " equipped!")


func _process(delta: float) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ Cooldown System                                                     │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Mỗi weapon có cooldown riêng                                        │
	# │                                                                     │
	# │ Flow:                                                               │
	# │ 1. can_attack = true, cooldown_timer = 0                            │
	# │ 2. _attack() được gọi                                               │
	# │ 3. can_attack = false, cooldown_timer = current_cooldown            │
	# │ 4. Mỗi frame: cooldown_timer -= delta                               │
	# │ 5. Khi cooldown_timer <= 0: can_attack = true                       │
	# │ 6. Lặp lại từ bước 2                                                │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Chỉ xử lý khi game đang chạy
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Cooldown countdown
	if not can_attack:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_attack = true
	
	# Auto attack khi có thể
	if can_attack:
		_attack()
		_start_cooldown()


# ═══════════════════════════════════════════════════════════════════════════
#                           ATTACK (Override in subclass)
# ═══════════════════════════════════════════════════════════════════════════

## OVERRIDE HÀM NÀY TRONG CLASS CON
## Đây là nơi spawn projectile hoặc thực hiện attack
func _attack() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Virtual Function / Method Override                         │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ Trong các ngôn ngữ OOP:                                             │
	# │   - "virtual" function = có thể override trong class con            │
	# │   - Class con ghi đè (override) behavior của class cha              │
	# │                                                                     │
	# │ Trong GDScript:                                                     │
	# │   - TẤT CẢ functions đều virtual (có thể override)                  │
	# │   - Chỉ cần định nghĩa lại function cùng tên trong class con        │
	# │                                                                     │
	# │ VÍ DỤ trong PhiKiem.gd:                                             │
	# │   func _attack() -> void:                                           │
	# │       # Spawn flying sword projectile                               │
	# │       var sword = sword_projectile.instantiate()                    │
	# │       # ...                                                         │
	# │                                                                     │
	# │ Khi PhiKiem._process() gọi _attack(), nó gọi VERSION CỦA PHIKEIM   │
	# │ không phải version của BaseWeapon!                                  │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Base implementation: Chỉ print warning
	push_warning("BaseWeapon._attack() called! Override this in subclass!")


## Bắt đầu cooldown
func _start_cooldown() -> void:
	can_attack = false
	cooldown_timer = current_cooldown


# ═══════════════════════════════════════════════════════════════════════════
#                           STAT CALCULATION
# ═══════════════════════════════════════════════════════════════════════════

## Tính toán lại stats dựa trên level và player bonuses
func recalculate_stats() -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ CÔNG THỨC STAT:                                                     │
	# │                                                                     │
	# │ Current = Base × (1 + Level Bonus) × Player Multiplier              │
	# │                                                                     │
	# │ VÍ DỤ cho Damage:                                                   │
	# │   Base: 10                                                          │
	# │   Level 5 bonus: +60%                                               │
	# │   Player Might multiplier: 1.2 (có Kim Cương Thể)                   │
	# │   → Current = 10 × 1.6 × 1.2 = 19.2 damage                          │
	# └─────────────────────────────────────────────────────────────────────┘
	
	# Lấy level bonuses (sẽ implement trong subclass)
	var level_bonus = _get_level_bonus()
	
	# Lấy player multipliers
	var p_might = 1.0
	var p_area = 1.0
	var p_speed = 1.0
	var p_duration = 1.0
	var p_cooldown = 1.0
	
	if player:
		p_might = player.might_multiplier
		p_area = player.area_multiplier
		p_speed = player.speed_multiplier
		p_duration = player.duration_multiplier
		p_cooldown = player.cooldown_multiplier
	
	# Calculate final stats
	current_damage = base_damage * (1 + level_bonus.get("damage", 0.0)) * p_might
	current_cooldown = base_cooldown * (1 - level_bonus.get("cooldown", 0.0)) * p_cooldown
	current_area = base_area * (1 + level_bonus.get("area", 0.0)) * p_area
	current_speed = base_speed * (1 + level_bonus.get("speed", 0.0)) * p_speed
	current_duration = base_duration * (1 + level_bonus.get("duration", 0.0)) * p_duration
	current_amount = base_amount + level_bonus.get("amount", 0)
	current_pierce = base_pierce + level_bonus.get("pierce", 0)
	current_knockback = base_knockback + level_bonus.get("knockback", 0.0)
	
	# Clamp cooldown (không xuống dưới 0.1 giây)
	current_cooldown = max(0.1, current_cooldown)


## Override trong subclass để định nghĩa bonus cho mỗi level
func _get_level_bonus() -> Dictionary:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ Trả về Dictionary chứa tổng bonus từ level 1 đến current_level      │
	# │                                                                     │
	# │ VD ở level 5:                                                       │
	# │   { "damage": 0.6, "amount": 2, "pierce": 1 }                       │
	# │   = +60% damage, +2 projectiles, +1 pierce                          │
	# └─────────────────────────────────────────────────────────────────────┘
	return {}  # Override in subclass


# ═══════════════════════════════════════════════════════════════════════════
#                           UPGRADE
# ═══════════════════════════════════════════════════════════════════════════

## Upgrade weapon lên level mới
func upgrade() -> void:
	if current_level >= max_level:
		print(weapon_name, " already at max level!")
		return
	
	current_level += 1
	recalculate_stats()
	
	print(weapon_name, " upgraded to level ", current_level)
	Events.weapon_upgraded.emit(weapon_id, current_level)


## Check xem đã max level chưa
func is_max_level() -> bool:
	return current_level >= max_level


# ═══════════════════════════════════════════════════════════════════════════
#                           EVOLUTION
# ═══════════════════════════════════════════════════════════════════════════

## Check xem có thể evolve không
## Override trong subclass để specify required passive
func can_evolve() -> bool:
	# Điều kiện:
	# 1. Đã max level
	# 2. Có passive item cần thiết (check trong subclass)
	return is_max_level()


## Get ID của weapon sau khi evolve
## Override trong subclass
func get_evolved_weapon_id() -> String:
	return ""  # Override in subclass


## Get ID của passive cần để evolve
## Override trong subclass
func get_required_passive_id() -> String:
	return ""  # Override in subclass
