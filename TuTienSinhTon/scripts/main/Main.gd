# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              MAIN SCENE                                   ║
# ║                    Entry point của gameplay                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Node2D


# Weapon scenes mapping
const WEAPON_SCENES = {
	"phi_kiem": "res://scenes/weapons/PhiKiem.tscn",
	"hoa_cau": "res://scenes/weapons/HoaCau.tscn",
	"loi_kich": "res://scenes/weapons/LoiKich.tscn",
}


func _ready() -> void:
	# Đăng ký Main scene với GameManager
	GameManager.main_scene = self
	
	# Get player reference
	var player = $Player
	
	# Apply selected character (nếu có)
	_apply_selected_character(player)
	
	# Apply meta powerups
	if player:
		MetaManager.apply_powerups_to_player(player)
	
	# Start run
	GameManager.start_run()
	
	print("Main scene loaded - Run started!")


func _apply_selected_character(player: Node) -> void:
	var char_data = GameManager.selected_character as CharacterData
	if not char_data:
		print("No character selected, using default")
		return
	
	if not player:
		return
	
	# Apply character bonuses
	char_data.apply_to_player(player, GameManager.current_level)
	
	# Load starting weapon
	var weapon_container = player.get_node_or_null("WeaponContainer")
	if weapon_container and char_data.starting_weapon_id != "":
		# Clear default weapons
		for child in weapon_container.get_children():
			child.queue_free()
		
		# Add character's starting weapon
		var weapon_path = WEAPON_SCENES.get(char_data.starting_weapon_id, "")
		if weapon_path != "":
			var weapon_scene = load(weapon_path)
			if weapon_scene:
				var weapon = weapon_scene.instantiate()
				weapon_container.call_deferred("add_child", weapon)
				print("Loaded starting weapon: ", char_data.starting_weapon_id)
	
	print("Applied character: ", char_data.character_name)
