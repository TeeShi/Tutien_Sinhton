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

var current_options: Array = []
var auto_upgrade_enabled: bool = false
var option_buttons: Array = []

# Gacha module
var gacha: GachaSelector = null


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	visible = false
	option_buttons = [option1, option2, option3]
	
	# Connect signals
	Events.level_up_started.connect(_on_level_up_started)
	option1.pressed.connect(func(): _select_option(0))
	option2.pressed.connect(func(): _select_option(1))
	option3.pressed.connect(func(): _select_option(2))
	
	# Tạo GachaSelector module
	gacha = GachaSelector.new()
	gacha.selection_finished.connect(_on_gacha_finished)
	add_child(gacha)


# ═══════════════════════════════════════════════════════════════════════════
#                           SIGNAL HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_level_up_started(new_level: int) -> void:
	title_label.text = "ĐỘT PHÁ! CẢNH GIỚI %d" % new_level
	_generate_options()
	visible = true
	
	if auto_upgrade_enabled:
		# Disable buttons, bắt đầu gacha
		for btn in option_buttons:
			btn.disabled = true
		gacha.start(option_buttons)
		# Không pause
	else:
		get_tree().paused = true


func _on_gacha_finished(selected_index: int) -> void:
	# Gacha animation kết thúc
	var selected = current_options[selected_index]
	_apply_upgrade(selected["id"])
	_show_notification(selected["name"], selected["description"], true)
	
	# Đợi một chút để user thấy kết quả
	await get_tree().create_timer(0.8).timeout
	
	# Ẩn UI
	visible = false
	
	# Reset buttons
	for btn in option_buttons:
		btn.disabled = false
		btn.modulate = Color.WHITE
	
	GameManager.exit_level_up()
	print("[AUTO] Selected: ", selected["name"])


func _generate_options() -> void:
	var shuffled = available_upgrades.duplicate()
	shuffled.shuffle()
	current_options = shuffled.slice(0, 3)
	
	option1.text = current_options[0]["name"]
	option2.text = current_options[1]["name"]
	option3.text = current_options[2]["name"]


func _select_option(index: int) -> void:
	if gacha and gacha.is_running:
		return  # Không cho click khi đang gacha
	
	var selected = current_options[index]
	_apply_upgrade(selected["id"])
	_show_notification(selected["name"], selected["description"], false)
	
	visible = false
	get_tree().paused = false
	GameManager.exit_level_up()
	print("Selected: ", selected["name"])


func _show_notification(skill_name: String, skill_desc: String, is_auto: bool) -> void:
	var notification = get_tree().root.find_child("UpgradeNotification", true, false)
	if notification and notification.has_method("show_upgrade"):
		notification.show_upgrade(skill_name, skill_desc, is_auto)


# ═══════════════════════════════════════════════════════════════════════════
#                           APPLY UPGRADES
# ═══════════════════════════════════════════════════════════════════════════

func _apply_upgrade(upgrade_id: String) -> void:
	var player = GameManager.player
	if not player:
		return
	
	match upgrade_id:
		"damage":
			_apply_to_all_weapons(func(w): w.base_damage *= 1.2)
		"speed":
			player.base_move_speed *= 1.1
		"proj_speed":
			_apply_to_all_weapons(func(w): 
				w.base_speed *= 1.15
				w.recalculate_stats()
			)
		"cooldown":
			_apply_to_all_weapons(func(w): w.base_cooldown *= 0.9)
		"area":
			_apply_to_all_weapons(func(w): w.base_area *= 1.15)
		"health":
			player.max_hp += 20
			player.current_hp = min(player.current_hp + 20, player.max_hp)
			Events.player_health_changed.emit(player.current_hp, player.max_hp)
		"regen":
			if player.has_method("add_hp_regen"):
				player.add_hp_regen(1)
		"amount":
			_apply_to_all_weapons(func(w): 
				w.base_amount += 1
				w.recalculate_stats()
			)
		"magnet":
			if player.has_node("MagnetArea/CollisionShape2D"):
				var shape = player.get_node("MagnetArea/CollisionShape2D").shape
				if shape is CircleShape2D:
					shape.radius *= 1.2


func _apply_to_all_weapons(callback: Callable) -> void:
	var player = GameManager.player
	if not player or not player.has_node("WeaponContainer"):
		return
	
	var weapon_container = player.get_node("WeaponContainer")
	for weapon in weapon_container.get_children():
		if weapon is BaseWeapon:
			callback.call(weapon)
