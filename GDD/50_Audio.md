# 🎵 Audio Design & Workflow

> Tài liệu chuẩn về thiết kế và quy trình làm việc với âm thanh trong game.
> **Có thể dùng làm template cho các dự án khác.**

---

## Mục lục

1. [Tong quan Audio](#tong-quan-audio)
2. [Cau truc Folder](#cau-truc-folder)
3. [Naming Conventions](#naming-conventions)
4. [Technical Specifications](#technical-specifications)
5. [Sound Categories](#sound-categories)
6. [Workflow](#workflow)
7. [Tools va Resources](#tools-va-resources)
8. [Integration Checklist](#integration-checklist)

---

## Tong quan Audio

### Tại sao Audio quan trọng?

| Yếu tố | Tác động |
|--------|----------|
| **Feedback** | Player biết action đã xảy ra |
| **Immersion** | Đắm chìm vào thế giới game |
| **Emotion** | Tạo cảm xúc (sợ, phấn khích, buồn) |
| **Polish** | Game có/không có sound = hoàn thiện/chưa xong |

### Nguyên tắc Audio trong Game

```
1. MỖI ACTION QUAN TRỌNG = 1 SOUND
   └── Hit, collect, level up, death...

2. KHÔNG CHỒNG CHÉO QUÁ NHIỀU
   └── Limit số sounds cùng lúc

3. VOLUME BALANCED
   └── Normalize tất cả audio

4. PLAYER CONTROL
   └── Cho phép điều chỉnh SFX/Music riêng
```

---

## Cau truc Folder

```
assets/audio/
│
├── sfx/                        # Sound Effects (< 5 giây)
│   │
│   ├── player/                 # Player-related
│   │   ├── footstep_*.ogg      # Bước chân
│   │   ├── hurt_*.ogg          # Bị thương
│   │   ├── death.ogg           # Chết
│   │   ├── level_up.ogg        # Lên level
│   │   ├── heal.ogg            # Hồi máu
│   │   └── dash.ogg            # Lướt
│   │
│   ├── combat/                 # Combat & Weapons
│   │   ├── hit_sword_*.ogg     # Kiếm trúng
│   │   ├── hit_fire_*.ogg      # Lửa trúng
│   │   ├── hit_lightning_*.ogg # Sét trúng
│   │   ├── swing_*.ogg         # Vung vũ khí
│   │   ├── cast_*.ogg          # Thi triển
│   │   └── explosion_*.ogg     # Nổ
│   │
│   ├── enemy/                  # Enemy sounds
│   │   ├── spawn_*.ogg         # Xuất hiện
│   │   ├── attack_*.ogg        # Tấn công
│   │   ├── death_*.ogg         # Chết
│   │   └── boss_*.ogg          # Boss-specific
│   │
│   ├── pickup/                 # Collection sounds
│   │   ├── gem_*.ogg           # XP gems
│   │   ├── gold_*.ogg          # Tiền
│   │   ├── health.ogg          # HP pickup
│   │   └── powerup.ogg         # Power-up
│   │
│   ├── ui/                     # User Interface
│   │   ├── click.ogg           # Click button
│   │   ├── hover.ogg           # Hover
│   │   ├── open_menu.ogg       # Mở menu
│   │   ├── close_menu.ogg      # Đóng menu
│   │   ├── confirm.ogg         # Xác nhận
│   │   └── cancel.ogg          # Hủy
│   │
│   └── environment/            # Ambient sounds
│       ├── wind.ogg            # Gió
│       ├── rain.ogg            # Mưa
│       ├── thunder.ogg         # Sấm
│       └── fire_loop.ogg       # Lửa cháy
│
├── music/                      # Background Music (> 30 giây)
│   │
│   ├── gameplay/               # In-game
│   │   ├── main_theme.ogg      # Theme chính
│   │   ├── exploration.ogg     # Khám phá
│   │   └── combat.ogg          # Chiến đấu
│   │
│   ├── menu/                   # Menu screens
│   │   ├── title_screen.ogg    # Màn hình chính
│   │   └── results.ogg         # Kết quả
│   │
│   └── boss/                   # Boss fights
│       ├── boss_intro.ogg      # Intro boss
│       └── boss_loop.ogg       # Loop boss fight
│
├── voice/                      # Voice lines (optional)
│   ├── narrator/               # Narrator VO
│   └── characters/             # Character VO
│
└── README.md                   # Documentation
```

---

## Naming Conventions

### Format chuẩn
```
[category]_[action]_[variation].[ext]
```

| Phần | Mô tả | Ví dụ |
|------|-------|-------|
| `category` | Loại đối tượng | `sword`, `fire`, `gem` |
| `action` | Hành động | `hit`, `swing`, `collect` |
| `variation` | Số thứ tự (nếu nhiều) | `01`, `02`, `03` |
| `ext` | Extension | `.ogg`, `.wav` |

### Ví dụ thực tế

```
✅ ĐÚNG:
sword_hit_01.ogg
sword_hit_02.ogg
fire_cast.ogg
gem_collect_01.ogg
boss_roar.ogg

❌ SAI:
Sound1.ogg
new_sound_final_v2.ogg
asdf.ogg
```

### Variations (khi có nhiều versions)

```
# Random variation = tự nhiên hơn
sword_hit_01.ogg  →  play random
sword_hit_02.ogg  →  để không lặp
sword_hit_03.ogg  →  cùng 1 sound
```

---

## Technical Specifications

### SFX (Sound Effects)

| Property | Recommended | Notes |
|----------|-------------|-------|
| **Format** | `.ogg` (Vorbis) | Nhỏ, chất lượng tốt |
| **Sample Rate** | 44100 Hz | Standard |
| **Channels** | Mono (1 ch) | SFX không cần stereo |
| **Bit Depth** | 16-bit | Đủ cho SFX |
| **Duration** | < 5 seconds | Ngắn gọn |
| **Loudness** | -12 dB to -6 dB | Normalized |

### Music

| Property | Recommended | Notes |
|----------|-------------|-------|
| **Format** | `.ogg` (Vorbis) | Stream, không load hết |
| **Sample Rate** | 44100 Hz | Standard |
| **Channels** | Stereo (2 ch) | Music cần stereo |
| **Bit Depth** | 16-bit | Đủ cho music |
| **Duration** | 60-180 seconds | Để loop |
| **Loudness** | -14 dB to -10 dB | Nhẹ hơn SFX |
| **Loop** | Seamless loop | Check loop points |

### Format Comparison

| Format | Size | Quality | Use Case |
|--------|------|---------|----------|
| `.wav` | Lớn | Lossless | Source files |
| `.ogg` | Nhỏ | Lossy (good) | Game assets ✅ |
| `.mp3` | Nhỏ | Lossy | Avoid (licensing) |

---

## Sound Categories

### Danh sách Sounds cần thiết

#### Player Sounds
- [ ] `hurt_*.ogg` - Bị thương (2-3 variations)
- [ ] `death.ogg` - Chết
- [ ] `level_up.ogg` - Lên cấp
- [ ] `heal.ogg` - Hồi máu

#### Combat Sounds
- [ ] `hit_*.ogg` - Đánh trúng (theo weapon type)
- [ ] `swing_*.ogg` - Vung vũ khí
- [ ] `cast_*.ogg` - Thi triển skill

#### Pickup Sounds
- [ ] `gem_collect.ogg` - Thu XP gem
- [ ] `gold_collect.ogg` - Thu gold
- [ ] `powerup.ogg` - Nhận buff

#### UI Sounds
- [ ] `click.ogg` - Click button
- [ ] `confirm.ogg` - Xác nhận
- [ ] `cancel.ogg` - Hủy

#### Music
- [ ] `main_theme.ogg` - Theme chính (loopable)
- [ ] `boss_fight.ogg` - Boss fight (loopable)
- [ ] `victory.ogg` - Chiến thắng (one-shot)
- [ ] `game_over.ogg` - Thua (one-shot)

---

## Workflow

### Quy trình tổng quát

```
┌─────────────────────────────────────────────────────────┐
│  1. PLANNING                                            │
│     └── Liệt kê tất cả sounds cần trong game            │
├─────────────────────────────────────────────────────────┤
│  2. SOURCING                                            │
│     ├── Option A: Download free sounds                  │
│     ├── Option B: Tự tạo với tools (SFXR, Audacity)     │
│     ├── Option C: Mua asset packs                       │
│     └── Option D: Thuê sound designer                   │
├─────────────────────────────────────────────────────────┤
│  3. PROCESSING                                          │
│     ├── Convert to .ogg                                 │
│     ├── Normalize volume (-12 dB)                       │
│     ├── Trim silence đầu/cuối                           │
│     └── Apply effects nếu cần                           │
├─────────────────────────────────────────────────────────┤
│  4. ORGANIZING                                          │
│     ├── Đặt tên theo convention                         │
│     └── Đặt vào đúng folder                             │
├─────────────────────────────────────────────────────────┤
│  5. INTEGRATING                                         │
│     ├── Import vào engine                               │
│     ├── Setup audio system                              │
│     └── Connect với game events                         │
├─────────────────────────────────────────────────────────┤
│  6. TESTING & BALANCING                                 │
│     ├── Test tất cả sounds trong context                │
│     ├── Balance volume giữa các sounds                  │
│     └── Adjust timing nếu cần                           │
└─────────────────────────────────────────────────────────┘
```

### Team Collaboration

```
SOUND DESIGNER              PROGRAMMER
─────────────────────────────────────────
1. Tạo sounds          →   
2. Đặt tên & organize  →   
3. Commit to repo      →   4. Pull và integrate
                       →   5. Map sound → action
                       →   6. Test
7. Review & adjust     ←   Feedback
```

---

## Tools va Resources

### Tools miễn phí

| Tool | Purpose | Platform |
|------|---------|----------|
| **Audacity** | Edit, convert, normalize | All |
| **SFXR/jsfxr** | Generate 8-bit SFX | Web/All |
| **BFXR** | Advanced SFXR | All |
| **Ocenaudio** | Simple editing | All |

### Tools trả phí (recommend)

| Tool | Purpose | Price |
|------|---------|-------|
| **Reaper** | Full DAW | $60 |
| **FL Studio** | Production | $99+ |
| **Ableton** | Production | $99+ |

### Free Sound Resources

| Source | URL | License |
|--------|-----|---------|
| Freesound | freesound.org | CC0/BY |
| OpenGameArt | opengameart.org | Various |
| Kenney | kenney.nl/assets | CC0 |
| Mixkit | mixkit.co | Free |
| SoundBible | soundbible.com | Various |
| ZapSplat | zapsplat.com | Free (attribution) |

### Paid Asset Packs

| Source | Type | Price Range |
|--------|------|-------------|
| Unity Asset Store | Packs | $5-50 |
| Humble Bundle | Bundles | $10-30 |
| GameDev Market | Packs | $5-30 |

---

## Integration Checklist

### Trước khi import

- [ ] Format: `.ogg` (hoặc `.wav` cho SFX ngắn)
- [ ] Sample rate: 44100 Hz
- [ ] Mono cho SFX, Stereo cho Music
- [ ] Volume normalized: -12 dB
- [ ] Silence trimmed
- [ ] Named correctly
- [ ] In correct folder

### Sau khi import (Godot)

```gdscript
# Preload sounds
var snd_hit = preload("res://assets/audio/sfx/combat/hit_sword_01.ogg")

# Play sound
audio_player.stream = snd_hit
audio_player.play()
```

### Testing checklist

- [ ] Sound plays at correct moment
- [ ] Volume balanced với sounds khác
- [ ] No clipping hoặc distortion
- [ ] Pitch variation (nếu cần)
- [ ] Stop/fade khi cần

---

## 🎛️ Godot Audio Setup

### Audio Bus Layout

```
Master
├── SFX        # All sound effects
│   ├── Combat
│   ├── UI
│   └── Pickup
└── Music      # Background music
```

### Import Settings

**SFX:**
```
Loop: Disabled
```

**Music (looping):**
```
Loop: Enabled
Loop Offset: [set loop point]
```

---

## 📝 Notes

- Luôn keep source files (WAV) riêng
- Game chỉ dùng compressed files (.ogg)
- Test trên nhiều devices (headphones, speakers)
- Consider accessibility (visual cues kèm sound)

---

*Document version: 1.0 | Last updated: December 2025*
