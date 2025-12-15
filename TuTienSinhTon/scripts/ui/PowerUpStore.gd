# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          POWERUP STORE                                     ║
# ║              UI mua PowerUps vĩnh viễn                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends CanvasLayer


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var panel: Panel = $Panel
@onready var gold_label: Label = $Panel/GoldLabel
@onready var powerups_container: VBoxContainer = $Panel/ScrollContainer/PowerUpsContainer
@onready var close_button: Button = $Panel/CloseButton
@onready var refund_button: Button = $Panel/RefundButton


# ═══════════════════════════════════════════════════════════════════════════
#                              LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	visible = false
	
	# Connect signals
	Events.gold_changed.connect(_on_gold_changed)
	close_button.pressed.connect(_close)
	refund_button.pressed.connect(_refund_all)
	
	# Build powerup list
	_build_powerup_list()


func _input(event: InputEvent) -> void:
	# Press P to toggle store
	if event.is_action_pressed("open_store"):
		toggle()


# ═══════════════════════════════════════════════════════════════════════════
#                              UI CONTROL
# ═══════════════════════════════════════════════════════════════════════════

func toggle() -> void:
	visible = !visible
	if visible:
		_refresh()
		get_tree().paused = true
	else:
		get_tree().paused = false


func _close() -> void:
	visible = false
	get_tree().paused = false


func _refund_all() -> void:
	MetaManager.refund_all()
	_refresh()


# ═══════════════════════════════════════════════════════════════════════════
#                           BUILD UI
# ═══════════════════════════════════════════════════════════════════════════

func _build_powerup_list() -> void:
	# Clear existing
	for child in powerups_container.get_children():
		child.queue_free()
	
	# Create item for each powerup
	for id in MetaManager.POWERUPS.keys():
		var data = MetaManager.POWERUPS[id]
		var item = _create_powerup_item(id, data)
		powerups_container.add_child(item)


func _create_powerup_item(powerup_id: String, data: Dictionary) -> Control:
	var hbox = HBoxContainer.new()
	hbox.name = powerup_id
	
	# Name label
	var name_label = Label.new()
	name_label.text = data["name"]
	name_label.custom_minimum_size.x = 100
	hbox.add_child(name_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = data["description"]
	desc_label.custom_minimum_size.x = 150
	desc_label.modulate = Color(0.7, 0.7, 0.7)
	hbox.add_child(desc_label)
	
	# Level indicator
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "0/%d" % data["max_level"]
	level_label.custom_minimum_size.x = 60
	hbox.add_child(level_label)
	
	# Cost label
	var cost_label = Label.new()
	cost_label.name = "CostLabel"
	cost_label.text = "%d 💎" % data["cost_per_level"]
	cost_label.custom_minimum_size.x = 80
	hbox.add_child(cost_label)
	
	# Buy button
	var buy_button = Button.new()
	buy_button.name = "BuyButton"
	buy_button.text = "Mua"
	buy_button.custom_minimum_size.x = 60
	buy_button.pressed.connect(func(): _buy_powerup(powerup_id))
	hbox.add_child(buy_button)
	
	return hbox


# ═══════════════════════════════════════════════════════════════════════════
#                           ACTIONS
# ═══════════════════════════════════════════════════════════════════════════

func _buy_powerup(powerup_id: String) -> void:
	if MetaManager.buy_powerup(powerup_id):
		_refresh()
		SoundManager.play_gem_collect() # Play sound
	else:
		print("Cannot buy: ", powerup_id)


func _refresh() -> void:
	# Update gold display
	gold_label.text = "💎 %d" % MetaManager.get_gold()
	
	# Update each powerup item
	for item in powerups_container.get_children():
		var powerup_id = item.name
		var data = MetaManager.POWERUPS.get(powerup_id)
		if not data:
			continue
		
		var current_level = MetaManager.get_powerup_level(powerup_id)
		var max_level = data["max_level"]
		
		# Update level label
		var level_label = item.get_node_or_null("LevelLabel")
		if level_label:
			level_label.text = "%d/%d" % [current_level, max_level]
			if current_level >= max_level:
				level_label.modulate = Color(0.3, 1.0, 0.3) # Green = maxed
		
		# Update buy button
		var buy_button = item.get_node_or_null("BuyButton")
		if buy_button:
			var can_buy = MetaManager.can_buy_powerup(powerup_id)
			buy_button.disabled = not can_buy
			if current_level >= max_level:
				buy_button.text = "MAX"
			else:
				buy_button.text = "Mua"


func _on_gold_changed(new_gold: int) -> void:
	if visible:
		_refresh()
