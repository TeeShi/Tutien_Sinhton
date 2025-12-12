# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              MAIN SCENE                                   ║
# ║                    Entry point của gameplay                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

extends Node2D


func _ready() -> void:
	# Đăng ký Main scene với GameManager
	GameManager.main_scene = self
	
	# Auto-start run khi Main scene load
	# (Sau này sẽ đổi thành từ Main Menu)
	GameManager.start_run()
	print("Main scene loaded - Run started!")
