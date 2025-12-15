# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                      CHARACTER SELECT                                      ║
# ║              Chọn Tu Sĩ trước khi bắt đầu run                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Control


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var characters_container: HBoxContainer = $CharactersContainer
@onready var confirm_button: Button = $ConfirmButton
@onready var back_button: Button = $BackButton
@onready var character_info: Label = $CharacterInfo


# ═══════════════════════════════════════════════════════════════════════════
#                              DATA
# ═══════════════════════════════════════════════════════════════════════════

# Character resource files
const CHARACTER_RESOURCES = [
	"res://resources/characters/kiem_tieu_sinh.tres",
	"res://resources/characters/hoa_linh_nhi.tres",
	"res://resources/characters/thuy_nguyet.tres",
]

var characters: Array[CharacterData] = []
var selected_index: int = 0
var character_buttons: Array[Button] = []


# ═══════════════════════════════════════════════════════════════════════════
#                              LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Load character data từ .tres files
	_load_characters()
	
	# Build character cards
	_build_character_cards()
	
	# Connect buttons
	confirm_button.pressed.connect(_on_confirm_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Select first by default
	if characters.size() > 0:
		_select_character(0)
	
	print("CharacterSelect ready, ", characters.size(), " characters loaded")


func _load_characters() -> void:
	for path in CHARACTER_RESOURCES:
		var char_data = load(path) as CharacterData
		if char_data:
			characters.append(char_data)
			print("Loaded: ", char_data.character_name)
		else:
			push_warning("Failed to load: ", path)


# ═══════════════════════════════════════════════════════════════════════════
#                           BUILD UI
# ═══════════════════════════════════════════════════════════════════════════

func _build_character_cards() -> void:
	for i in range(characters.size()):
		var char_data = characters[i]
		var card = _create_character_card(char_data, i)
		characters_container.add_child(card)
		character_buttons.append(card)


func _create_character_card(char_data: CharacterData, index: int) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 250)
	button.toggle_mode = true
	
	# Build card content
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Character visual (placeholder)
	var preview = ColorRect.new()
	preview.custom_minimum_size = Vector2(80, 80)
	preview.color = char_data.sprite_color
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(preview)
	
	# Name
	var name_label = Label.new()
	name_label.text = char_data.character_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)
	
	# Linh Can
	var linh_can_label = Label.new()
	linh_can_label.text = char_data.linh_can + " Hệ"
	linh_can_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	linh_can_label.modulate = Color(0.7, 0.7, 0.7)
	linh_can_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(linh_can_label)
	
	# Passive bonus
	var passive_label = Label.new()
	passive_label.text = _get_passive_text(char_data)
	passive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	passive_label.modulate = Color(0.3, 1.0, 0.3)
	passive_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(passive_label)
	
	button.add_child(vbox)
	button.pressed.connect(func(): _select_character(index))
	
	return button


func _get_passive_text(char_data: CharacterData) -> String:
	if char_data.bonus_damage > 0:
		return "+%d%% Damage" % int(char_data.bonus_damage * 100)
	elif char_data.bonus_area > 0:
		return "+%d%% Area" % int(char_data.bonus_area * 100)
	elif char_data.bonus_cooldown < 0:
		return "%d%% Cooldown" % int(char_data.bonus_cooldown * 100)
	elif char_data.bonus_max_hp > 0:
		return "+%d%% HP" % int(char_data.bonus_max_hp * 100)
	elif char_data.bonus_recovery > 0:
		return "+%.1f HP/s" % char_data.bonus_recovery
	return ""


# ═══════════════════════════════════════════════════════════════════════════
#                           SELECTION
# ═══════════════════════════════════════════════════════════════════════════

func _select_character(index: int) -> void:
	selected_index = index
	
	# Update button states
	for i in range(character_buttons.size()):
		character_buttons[i].button_pressed = (i == index)
	
	# Update info
	var char_data = characters[index]
	character_info.text = '"%s"\n\nVũ khí: %s' % [char_data.lore, char_data.starting_weapon_id.capitalize()]


# ═══════════════════════════════════════════════════════════════════════════
#                           ACTIONS
# ═══════════════════════════════════════════════════════════════════════════

func _on_confirm_pressed() -> void:
	# Store selected character
	var selected_char = characters[selected_index]
	GameManager.selected_character = selected_char
	
	# Start game
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")
