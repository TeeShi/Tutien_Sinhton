# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          MAIN MENU                                        ║
# ║              Menu chính của game                                          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Control


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var store_button: Button = $VBoxContainer/StoreButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var gold_label: Label = $GoldLabel


# ═══════════════════════════════════════════════════════════════════════════
#                              LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	store_button.pressed.connect(_on_store_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Update gold display
	_update_gold()
	Events.gold_changed.connect(_on_gold_changed)
	
	# Ensure not paused
	get_tree().paused = false


# ═══════════════════════════════════════════════════════════════════════════
#                           BUTTON HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_start_pressed() -> void:
	# Go to character select
	get_tree().change_scene_to_file("res://scenes/menu/CharacterSelect.tscn")


func _on_store_pressed() -> void:
	# Open PowerUp store
	var store = get_tree().root.find_child("PowerUpStore", true, false)
	if store:
		store.toggle()
	else:
		# Instantiate store if not exists
		var store_scene = preload("res://scenes/ui/PowerUpStore.tscn")
		var store_instance = store_scene.instantiate()
		add_child(store_instance)
		store_instance.toggle()


func _on_quit_pressed() -> void:
	get_tree().quit()


# ═══════════════════════════════════════════════════════════════════════════
#                              UI
# ═══════════════════════════════════════════════════════════════════════════

func _update_gold() -> void:
	gold_label.text = "💎 %d" % MetaManager.get_gold()


func _on_gold_changed(_new_gold: int) -> void:
	_update_gold()
