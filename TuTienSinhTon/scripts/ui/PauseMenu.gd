# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          PAUSE MENU                                       ║
# ║              Menu tạm dừng game khi nhấn ESC                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Input Handling trong UI                                       │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ CÁCH XỬ LÝ INPUT:                                                       │
# │   1. _input(event) - Mọi input event (mouse, keyboard, touch)           │
# │   2. _unhandled_input(event) - Input chưa được xử lý bởi UI             │
# │   3. Input.is_action_just_pressed() - Check action trong _process       │
# │                                                                         │
# │ UI NÊN DÙNG _input() để:                                                │
# │   - Bắt input TRƯỚC khi game logic                                      │
# │   - Không bị ảnh hưởng bởi pause                                        │
# │                                                                         │
# │ PROCESS_MODE_ALWAYS:                                                    │
# │   - Node vẫn chạy khi game paused                                       │
# │   - Cần cho Pause Menu vì game đang pause!                              │
# └─────────────────────────────────────────────────────────────────────────┘

extends CanvasLayer


# ═══════════════════════════════════════════════════════════════════════════
#                              REFERENCES
# ═══════════════════════════════════════════════════════════════════════════

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Ẩn ban đầu
	visible = false
	
	# Connect buttons
	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)


# ═══════════════════════════════════════════════════════════════════════════
#                           INPUT HANDLING
# ═══════════════════════════════════════════════════════════════════════════

func _input(event: InputEvent) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: InputEvent và is_action_pressed                            │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ InputEvent = Object chứa thông tin về input                         │
	# │                                                                     │
	# │ is_action_pressed("action_name"):                                   │
	# │   - Check xem action có được nhấn không                             │
	# │   - Action được định nghĩa trong Project Settings > Input Map       │
	# │   - "ui_cancel" = ESC key (built-in action)                         │
	# │                                                                     │
	# │ TẠI SAO DÙNG _input() THAY VÌ _process()?                           │
	# │   - _input() chạy ngay khi có input                                 │
	# │   - _process() có thể bị delay                                      │
	# │   - UI cần phản hồi TỨC THÌ với input                               │
	# └─────────────────────────────────────────────────────────────────────┘
	
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_toggle_pause()


func _toggle_pause() -> void:
	# Không toggle nếu đang level up, game over, hay victory
	if GameManager.current_state == GameManager.GameState.LEVEL_UP:
		return
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		return
	if GameManager.current_state == GameManager.GameState.VICTORY:
		return
	
	if visible:
		# Đang pause → Resume
		_on_resume()
	else:
		# Đang chơi → Pause
		visible = true
		get_tree().paused = true
		GameManager.current_state = GameManager.GameState.PAUSED
		Events.game_paused.emit()


# ═══════════════════════════════════════════════════════════════════════════
#                           BUTTON HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

func _on_resume() -> void:
	visible = false
	get_tree().paused = false
	GameManager.current_state = GameManager.GameState.PLAYING
	Events.game_resumed.emit()


func _on_restart() -> void:
	visible = false
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()


func _on_quit() -> void:
	get_tree().quit()
