# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          LEVEL UP UI                                      ║
# ║                    Hiển thị khi player level up                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends CanvasLayer


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var options_container: HBoxContainer = $Panel/VBoxContainer/OptionsContainer
@onready var option1: Button = $Panel/VBoxContainer/OptionsContainer/Option1
@onready var option2: Button = $Panel/VBoxContainer/OptionsContainer/Option2
@onready var option3: Button = $Panel/VBoxContainer/OptionsContainer/Option3


# ═══════════════════════════════════════════════════════════════════════════
#                              DATA
# ═══════════════════════════════════════════════════════════════════════════

# Danh sách upgrades có thể
var available_upgrades: Array = [
	{"id": "damage", "name": "+20% Công Lực", "description": "Tăng damage cho tất cả vũ khí"},
	{"id": "speed", "name": "+10% Thân Pháp", "description": "Tăng tốc độ di chuyển"},
	{"id": "proj_speed", "name": "+15% Kiếm Khí", "description": "Tăng tốc độ đạn bay"},
	{"id": "cooldown", "name": "-10% Hồi Chiêu", "description": "Giảm cooldown vũ khí"},
	{"id": "area", "name": "+15% Phạm Vi", "description": "Tăng vùng ảnh hưởng"},
	{"id": "health", "name": "+20 HP", "description": "Tăng máu tối đa"},
	{"id": "regen", "name": "+1 Hồi Máu", "description": "Hồi 1 HP mỗi giây"},
	{"id": "amount", "name": "+1 Projectile", "description": "Thêm 1 projectile cho vũ khí"},
	{"id": "magnet", "name": "+20% Hút XP", "description": "Tăng phạm vi hút XP"},
]

var current_options: Array = []  # 3 options đang hiển thị


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Ẩn ban đầu
	visible = false
	
	# Connect signals
	Events.level_up_started.connect(_on_level_up_started)
	option1.pressed.connect(func(): _select_option(0))
	option2.pressed.connect(func(): _select_option(1))
	option3.pressed.connect(func(): _select_option(2))


# ═══════════════════════════════════════════════════════════════════════════
#                           SIGNAL HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_level_up_started(new_level: int) -> void:
	# Cập nhật title
	title_label.text = "ĐỘT PHÁ! CẢNH GIỚI %d" % new_level
	
	# Random 3 options
	_generate_options()
	
	# Hiển thị UI
	visible = true
	
	# Pause game
	get_tree().paused = true


func _generate_options() -> void:
	# Shuffle và lấy 3 options
	var shuffled = available_upgrades.duplicate()
	shuffled.shuffle()
	current_options = shuffled.slice(0, 3)
	
	# Update buttons
	option1.text = current_options[0]["name"]
	option2.text = current_options[1]["name"]
	option3.text = current_options[2]["name"]


func _select_option(index: int) -> void:
	var selected = current_options[index]
	
	# Apply upgrade
	_apply_upgrade(selected["id"])
	
	# Ẩn UI
	visible = false
	
	# Resume game
	get_tree().paused = false
	GameManager.exit_level_up()
	
	print("Selected upgrade: ", selected["name"])


func _apply_upgrade(upgrade_id: String) -> void:
	# Lấy player reference
	var player = GameManager.player
	if not player:
		return
	
	# Apply dựa trên ID
	match upgrade_id:
		"damage":
			# Tăng damage cho tất cả weapons
			_apply_to_all_weapons(func(w): w.base_damage *= 1.2)
		"speed":
			player.base_move_speed *= 1.1
		"proj_speed":
			# Tăng tốc độ đạn cho tất cả weapons
			_apply_to_all_weapons(func(w): 
				w.base_speed *= 1.15
				w.recalculate_stats()
			)
		"cooldown":
			# Giảm cooldown cho tất cả weapons
			_apply_to_all_weapons(func(w): w.base_cooldown *= 0.9)
		"area":
			# Tăng area cho tất cả weapons
			_apply_to_all_weapons(func(w): w.base_area *= 1.15)
		"health":
			player.max_hp += 20
			player.current_hp = min(player.current_hp + 20, player.max_hp)
			Events.player_health_changed.emit(player.current_hp, player.max_hp)
		"regen":
			# Tăng HP regen (cần thêm vào Player sau)
			if player.has_method("add_hp_regen"):
				player.add_hp_regen(1)
		"amount":
			# Tăng projectile amount cho tất cả weapons
			_apply_to_all_weapons(func(w): 
				w.base_amount += 1
				w.recalculate_stats()
			)
		"magnet":
			# Tăng magnet radius
			if player.has_node("MagnetArea/CollisionShape2D"):
				var shape = player.get_node("MagnetArea/CollisionShape2D").shape
				if shape is CircleShape2D:
					shape.radius *= 1.2


func _apply_to_all_weapons(callback: Callable) -> void:
	# Tìm tất cả weapons trong WeaponContainer
	var player = GameManager.player
	if not player or not player.has_node("WeaponContainer"):
		return
	
	var weapon_container = player.get_node("WeaponContainer")
	for weapon in weapon_container.get_children():
		if weapon is BaseWeapon:
			callback.call(weapon)

