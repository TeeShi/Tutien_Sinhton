# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          SOUND MANAGER                                    ║
# ║              Quản lý tất cả âm thanh trong game                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Audio trong Games                                               │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ ÂM THANH RẤT QUAN TRỌNG:                                                 │
# │   - Tạo feedback tức thì cho hành động                                   │
# │   - Tăng "game feel" đáng kể                                             │
# │   - Game không có sound = game chưa hoàn thiện                           │
# │                                                                         │
# │ NGUYÊN TẮC AUDIO:                                                        │
# │   1. Mỗi action quan trọng cần có sound                                  │
# │   2. Sound không được chồng chéo quá nhiều                               │
# │   3. Volume cần balanced (không quá to/nhỏ)                              │
# │   4. SFX vs Music cần tách biệt để user control                          │
# │                                                                         │
# │ GODOT AUDIO NODES:                                                       │
# │   - AudioStreamPlayer: 2D không có vị trí                                │
# │   - AudioStreamPlayer2D: Có vị trí trong game world                      │
# │   - AudioStreamPlayer3D: Âm thanh 3D                                     │
# └─────────────────────────────────────────────────────────────────────────┘

extends Node


# ═══════════════════════════════════════════════════════════════════════════
#                              AUDIO POOLS
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Object Pooling cho Audio                                       │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ VẤN ĐỀ: Nếu tạo mới AudioStreamPlayer mỗi lần play → lag                │
# │                                                                         │
# │ GIẢI PHÁP: Tạo sẵn nhiều players, dùng lại                              │
# │   - Pool = nhóm các objects đã tạo sẵn                                  │
# │   - Khi cần play → lấy player rảnh từ pool                              │
# │   - Khi play xong → trả lại pool                                        │
# └─────────────────────────────────────────────────────────────────────────┘

const POOL_SIZE: int = 8  # Số AudioStreamPlayer tạo sẵn

var sfx_pool: Array[AudioStreamPlayer] = []
var current_pool_index: int = 0


# ═══════════════════════════════════════════════════════════════════════════
#                              SOUND RESOURCES
# ═══════════════════════════════════════════════════════════════════════════

# Preload sounds (sẽ thêm files sau)
# var snd_attack = preload("res://assets/sounds/attack.wav")
# var snd_hit = preload("res://assets/sounds/hit.wav")

# Volume settings (dB)
var master_volume: float = 0.0
var sfx_volume: float = 0.0
var music_volume: float = -10.0


# ═══════════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Tạo pool AudioStreamPlayers
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"  # Sử dụng SFX bus
		add_child(player)
		sfx_pool.append(player)
	
	print("SoundManager initialized with pool size: ", POOL_SIZE)


# ═══════════════════════════════════════════════════════════════════════════
#                           PUBLIC METHODS
# ═══════════════════════════════════════════════════════════════════════════

## Play một sound effect
func play_sfx(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: Match Statement                                            │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ match = switch/case trong GDScript                                  │
	# │ Dùng để chọn action dựa trên value                                  │
	# │                                                                     │
	# │ Syntax:                                                             │
	# │   match value:                                                      │
	# │       "case1": do_something()                                       │
	# │       "case2": do_another()                                         │
	# │       _: default_action()  # _ = default                            │
	# └─────────────────────────────────────────────────────────────────────┘
	
	var stream: AudioStream = null
	
	match sound_name:
		"attack":
			stream = _generate_attack_sound()
		"hit":
			stream = _generate_hit_sound()
		"level_up":
			stream = _generate_level_up_sound()
		"gem_collect":
			stream = _generate_gem_sound()
		"gold_collect":
			stream = _generate_gold_sound()
		"player_hurt":
			stream = _generate_hurt_sound()
		"boss_spawn":
			stream = _generate_boss_sound()
		_:
			push_warning("SoundManager: Unknown sound: ", sound_name)
			return
	
	if stream:
		_play_from_pool(stream, volume_db, pitch_scale)


## Shortcut methods cho các sounds thường dùng
func play_attack() -> void:
	play_sfx("attack", -25.0, randf_range(0.9, 1.1))

func play_hit() -> void:
	play_sfx("hit", -20.0, randf_range(0.8, 1.2))

func play_level_up() -> void:
	play_sfx("level_up", -15.0, 1.0)

func play_gem_collect() -> void:
	play_sfx("gem_collect", -25.0, randf_range(1.0, 1.3))

func play_gold_collect() -> void:
	# Gold pickup sound - higher pitch than gem
	play_sfx("gold_collect", -22.0, randf_range(0.9, 1.1))

func play_player_hurt() -> void:
	play_sfx("player_hurt", -18.0, 1.0)

func play_boss_spawn() -> void:
	play_sfx("boss_spawn", -10.0, 0.8)


# ═══════════════════════════════════════════════════════════════════════════
#                           INTERNAL METHODS
# ═══════════════════════════════════════════════════════════════════════════

func _play_from_pool(stream: AudioStream, volume_db: float, pitch_scale: float) -> void:
	# Tìm player rảnh trong pool (round-robin)
	var player = sfx_pool[current_pool_index]
	current_pool_index = (current_pool_index + 1) % POOL_SIZE
	
	player.stream = stream
	player.volume_db = volume_db + sfx_volume
	player.pitch_scale = pitch_scale
	player.play()


# ═══════════════════════════════════════════════════════════════════════════
#                     REAL AUDIO ASSETS (Kenney Pack)
# ═══════════════════════════════════════════════════════════════════════════
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ BÀI HỌC: Tổ chức Audio Assets                                           │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ 1. PRELOAD: Load sounds khi game khởi động (không lag khi play)        │
# │    var sound = preload("res://path/to/sound.ogg")                       │
# │                                                                         │
# │ 2. ARRAY SOUNDS: Nhiều variations → game không bị lặp, tự nhiên hơn    │
# │    var sounds = [sound1, sound2, sound3]                                │
# │    sounds[randi() % sounds.size()]  # Random pick                       │
# │                                                                         │
# │ 3. OGG FORMAT: Nhẹ hơn WAV, tốt cho game                                │
# │                                                                         │
# │ 4. FOLDER STRUCTURE:                                                    │
# │    sfx/player/   - Footsteps, hurt, death                               │
# │    sfx/combat/   - Weapon swings, hits                                  │
# │    sfx/pickup/   - Coins, gems, items                                   │
# │    sfx/ui/       - Clicks, level up, menus                              │
# └─────────────────────────────────────────────────────────────────────────┘

# Combat sounds - nhiều variations để không bị lặp
var attack_sounds = [
	preload("res://assets/audio/sfx/combat/knifeSlice.ogg"),
	preload("res://assets/audio/sfx/combat/knifeSlice2.ogg"),
	preload("res://assets/audio/sfx/combat/chop.ogg"),
]

var hit_sounds = [
	preload("res://assets/audio/sfx/combat/drawKnife1.ogg"),
	preload("res://assets/audio/sfx/combat/drawKnife2.ogg"),
]

# Pickup sounds
var gem_sounds = [
	preload("res://assets/audio/sfx/pickup/handleCoins.ogg"),
	preload("res://assets/audio/sfx/pickup/handleCoins2.ogg"),
]

# UI sounds
var level_up_sound = preload("res://assets/audio/sfx/ui/bookOpen.ogg")
var menu_click_sound = preload("res://assets/audio/sfx/ui/metalClick.ogg")

# Player sounds
var hurt_sounds = [
	preload("res://assets/audio/sfx/player/cloth1.ogg"),
	preload("res://assets/audio/sfx/player/cloth2.ogg"),
]

func _generate_attack_sound() -> AudioStream:
	return attack_sounds[randi() % attack_sounds.size()]

func _generate_hit_sound() -> AudioStream:
	return hit_sounds[randi() % hit_sounds.size()]

func _generate_level_up_sound() -> AudioStream:
	return level_up_sound

func _generate_gem_sound() -> AudioStream:
	return gem_sounds[randi() % gem_sounds.size()]

func _generate_gold_sound() -> AudioStream:
	# Gold dùng coins sound nhưng pitch khác gem
	return gem_sounds[randi() % gem_sounds.size()]

func _generate_hurt_sound() -> AudioStream:
	return hurt_sounds[randi() % hurt_sounds.size()]

func _generate_boss_sound() -> AudioStream:
	# Dùng creak cho hiệu ứng boss (scary)
	return preload("res://assets/audio/sfx/environment/creak1.ogg")


func _create_noise_burst(duration: float, frequency: float, volume: float) -> AudioStreamWAV:
	# ┌─────────────────────────────────────────────────────────────────────┐
	# │ BÀI HỌC: AudioStreamWAV                                             │
	# ├─────────────────────────────────────────────────────────────────────┤
	# │ AudioStreamWAV cho phép tạo audio data bằng code                    │
	# │ - mix_rate: Số samples/giây (44100 = CD quality)                    │
	# │ - format: 8-bit hoặc 16-bit                                         │
	# │ - data: PackedByteArray chứa audio samples                          │
	# └─────────────────────────────────────────────────────────────────────┘
	
	var sample_rate = 22050
	var num_samples = int(duration * sample_rate)
	
	var audio = AudioStreamWAV.new()
	audio.mix_rate = sample_rate
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / sample_rate
		var progress = float(i) / num_samples
		
		# Smooth envelope: quick attack, gradual release
		# sin(pi * progress) gives nice bell curve shape
		var envelope = sin(progress * PI) * (1.0 - progress * 0.5)
		
		# Pure sine wave (no harsh noise)
		var sample = sin(t * frequency * TAU) * envelope * volume * 0.3
		
		# Convert to 8-bit (0-255, center at 128)
		data[i] = int(clamp(sample * 127 + 128, 0, 255))
	
	audio.data = data
	return audio
