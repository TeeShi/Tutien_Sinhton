# 🎵 Audio Assets Structure
> Standard audio folder structure for game development

## 📁 Folder Structure

```
audio/
├── sfx/                    # Sound Effects (ngắn, < 5 giây)
│   ├── player/             # Player-related sounds
│   │   ├── footstep_*.ogg
│   │   ├── hurt_*.ogg
│   │   ├── death.ogg
│   │   ├── level_up.ogg
│   │   ├── heal.ogg
│   │   └── dash.ogg
│   │
│   ├── combat/             # Combat & weapon sounds
│   │   ├── hit_sword_*.ogg
│   │   ├── hit_fire_*.ogg
│   │   ├── hit_lightning_*.ogg
│   │   ├── swing_*.ogg
│   │   ├── cast_*.ogg
│   │   └── explosion_*.ogg
│   │
│   ├── enemy/              # Enemy-specific sounds
│   │   ├── spawn_*.ogg
│   │   ├── attack_*.ogg
│   │   ├── death_*.ogg
│   │   └── boss_roar.ogg
│   │
│   ├── pickup/             # Item collection sounds
│   │   ├── gem_*.ogg
│   │   ├── gold_*.ogg
│   │   ├── health.ogg
│   │   └── powerup.ogg
│   │
│   ├── ui/                 # User interface sounds
│   │   ├── click.ogg
│   │   ├── hover.ogg
│   │   ├── open_menu.ogg
│   │   ├── close_menu.ogg
│   │   ├── confirm.ogg
│   │   └── cancel.ogg
│   │
│   └── environment/        # Ambient & environmental
│       ├── wind.ogg
│       ├── rain.ogg
│       ├── thunder.ogg
│       └── fire_loop.ogg
│
├── music/                  # Background music (dài, > 30 giây)
│   ├── gameplay/           # In-game music
│   │   ├── main_theme.ogg
│   │   ├── exploration.ogg
│   │   └── combat.ogg
│   │
│   ├── menu/               # Menu & UI music
│   │   ├── title_screen.ogg
│   │   └── results.ogg
│   │
│   └── boss/               # Boss fight music
│       ├── boss_intro.ogg
│       └── boss_loop.ogg
│
└── voice/                  # Voice lines (if any)
    ├── narrator/
    └── characters/
```

---

## 🏷️ Naming Conventions

### Format: `[category]_[action]_[variation].ogg`

| Part | Description | Example |
|------|-------------|---------|
| category | Loại đối tượng | `sword`, `fire`, `gem` |
| action | Hành động | `hit`, `swing`, `collect` |
| variation | Số thứ tự (optional) | `01`, `02`, `03` |

### Examples:
```
sword_hit_01.ogg      # Kiếm chém trúng, version 1
sword_hit_02.ogg      # Kiếm chém trúng, version 2
fire_cast.ogg         # Thi triển lửa
gem_collect_01.ogg    # Nhặt gem, version 1
```

---

## 🔧 Technical Specifications

### SFX (Sound Effects)
| Property | Recommended Value |
|----------|-------------------|
| Format | `.ogg` (Vorbis) |
| Sample Rate | 44100 Hz |
| Channels | Mono (1 channel) |
| Bit Depth | 16-bit |
| Duration | < 5 seconds |
| Loudness | -12 dB to -6 dB |

### Music
| Property | Recommended Value |
|----------|-------------------|
| Format | `.ogg` (Vorbis) |
| Sample Rate | 44100 Hz |
| Channels | Stereo (2 channels) |
| Bit Depth | 16-bit |
| Duration | 60-180 seconds |
| Loudness | -14 dB to -10 dB |
| Loop Points | Clean loop if needed |

---

## 🛠️ Tools Recommended

| Tool | Purpose | Cost |
|------|---------|------|
| **Audacity** | Editing, converting, normalizing | Free |
| **SFXR/jsfxr** | Generate retro SFX | Free |
| **BFXR** | More advanced SFXR | Free |
| **Reaper** | Professional DAW | $60 (free trial) |

---

## 📥 Free Audio Resources

| Source | URL | License |
|--------|-----|---------|
| Freesound | freesound.org | CC0/BY |
| OpenGameArt | opengameart.org | Various |
| Kenney | kenney.nl/assets | CC0 |
| Mixkit | mixkit.co/free-sound-effects | Free |

---

## ✅ Checklist Before Importing

- [ ] Format converted to `.ogg`
- [ ] Sample rate is 44100 Hz
- [ ] Volume normalized (-12 dB)
- [ ] Silence trimmed from start/end
- [ ] Named following convention
- [ ] Placed in correct folder

---

## 🎮 Godot Import Settings

For SFX:
```
Loop: OFF
```

For Music:
```
Loop: ON (if looping track)
```
