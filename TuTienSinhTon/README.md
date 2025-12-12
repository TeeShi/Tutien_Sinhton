# 🎮 Tu Tiên Sinh Tồn - Godot 4 Project

> **Survival Cultivation Game** - Vampire Survivors-like với theme Tu Tiên

## 🚀 Quick Start

1. **Mở project trong Godot 4.2+**
2. **Tạo các Scene** theo hướng dẫn bên dưới
3. **Chạy game** với F5

---

## 📁 Cấu Trúc Thư Mục

```
TuTienSinhTon/
├── project.godot           # 📋 Config chính (đã có)
├── icon.svg                # 🖼️ Icon game (cần tạo)
│
├── scenes/
│   ├── main/
│   │   └── Main.tscn       # 🏠 Scene chính (CÁCH TẠO BÊN DƯỚI)
│   │
│   ├── player/
│   │   └── Player.tscn     # 🧙 Tu Sĩ (CÁCH TẠO BÊN DƯỚI)
│   │
│   ├── enemies/
│   │   └── TieuYeuTrung.tscn # 👹 Enemy cơ bản
│   │
│   ├── weapons/
│   │   └── PhiKiem.tscn    # ⚔️ Weapon đầu tiên
│   │
│   ├── projectiles/
│   │   └── SwordProjectile.tscn # 🗡️ Đạn kiếm
│   │
│   ├── pickups/
│   │   └── XPGem.tscn      # 💎 Linh Khí
│   │
│   └── ui/
│       └── HUD.tscn        # 📊 Giao diện
│
├── scripts/
│   ├── autoload/           # 🌍 Singletons (đã có)
│   │   ├── GameManager.gd
│   │   └── Events.gd
│   │
│   ├── player/             # 🧙 Player scripts (đã có)
│   │   └── Player.gd
│   │
│   ├── enemies/            # 👹 Enemy scripts (đã có)
│   │   ├── BaseEnemy.gd
│   │   └── TieuYeuTrung.gd
│   │
│   ├── weapons/            # ⚔️ Weapon scripts (đã có)
│   │   ├── BaseWeapon.gd
│   │   └── PhiKiem.gd
│   │
│   └── systems/            # 🔧 Core systems (đã có)
│       └── EnemySpawner.gd
│
├── assets/
│   ├── sprites/            # 🖼️ Hình ảnh
│   ├── audio/              # 🔊 Âm thanh
│   └── fonts/              # 📝 Fonts
│
└── GDD/                    # 📚 Game Design Document (đã có)
```

---

## 🔨 HƯỚNG DẪN TẠO SCENE

### 1️⃣ Player.tscn

Trong Godot Editor:

1. **Scene → New Scene**
2. **Chọn "Other Node" → CharacterBody2D** (node gốc)
3. **Rename** thành "Player"
4. **Attach script**: `res://scripts/player/Player.gd`

**Thêm children:**
```
Player (CharacterBody2D) ← script: Player.gd
├── Sprite2D              ← Hình nhân vật
├── CollisionShape2D      ← Có CircleShape2D
├── MagnetArea (Area2D)   ← Vùng hút XP
│   └── CollisionShape2D  ← CircleShape2D lớn hơn
├── Hurtbox (Area2D)      ← Vùng nhận damage
│   └── CollisionShape2D  ← Cùng size với collision player
└── WeaponContainer (Node2D) ← Chứa weapons
```

**Collision Layers:**
- Player layer: 1 (player)
- Player mask: 2, 4 (enemy, pickup)
- Hurtbox layer: 1, mask: 2

**Save**: `res://scenes/player/Player.tscn`

---

### 2️⃣ TieuYeuTrung.tscn

1. **Scene → New Scene**
2. **Chọn CharacterBody2D** làm root
3. **Rename** thành "TieuYeuTrung"
4. **Attach script**: `res://scripts/enemies/TieuYeuTrung.gd`

**Thêm children:**
```
TieuYeuTrung (CharacterBody2D) ← script: TieuYeuTrung.gd
├── Sprite2D              ← Hình con yêu
├── CollisionShape2D      ← CircleShape2D nhỏ
└── Hitbox (Area2D)       ← Vùng gây damage cho player
    └── CollisionShape2D  ← Cùng size
```

**Collision Layers:**
- Enemy layer: 2 (enemy)
- Enemy mask: 1, 3 (player, player_projectile)
- Hitbox layer: 2, mask: 1

**Save**: `res://scenes/enemies/TieuYeuTrung.tscn`

---

### 3️⃣ Main.tscn

1. **Scene → New Scene**
2. **Chọn Node2D** làm root
3. **Rename** thành "Main"

**Thêm children:**
```
Main (Node2D)
├── Background (Sprite2D) ← Nền đất/cỏ
├── Player              ← Instance của Player.tscn
├── EnemySpawner (Node2D) ← script: EnemySpawner.gd
└── UI (CanvasLayer)
    └── HUD              ← UI elements
```

**Cách thêm Player scene:**
1. Kéo `Player.tscn` từ FileSystem vào Scene tree
2. Hoặc chuột phải → Instantiate Child Scene

**Save**: `res://scenes/main/Main.tscn`

---

## 📖 BÀI HỌC TRONG CODE

Mỗi file script đều có **comments chi tiết** giải thích:

| Script | Bài học chính |
|--------|---------------|
| `project.godot` | Config, Input mapping, Layers |
| `GameManager.gd` | Singleton, Enum, Game State |
| `Events.gd` | Signal Bus Pattern |
| `Player.gd` | CharacterBody2D, Export, OnReady |
| `BaseWeapon.gd` | Inheritance, Virtual Functions |
| `BaseEnemy.gd` | Vector Math, Groups |
| `PhiKiem.gd` | Preload, Super, Spread Pattern |
| `EnemySpawner.gd` | Spawn Algorithm, Weighted Random |

**Đọc comments trong code = Học GDScript!** 📚

---

## ✅ Checklist Trước Khi Chạy

- [ ] Tạo `Player.tscn` với đúng children
- [ ] Tạo `TieuYeuTrung.tscn`
- [ ] Tạo `Main.tscn` và instance Player vào
- [ ] Thêm Sprite2D placeholder cho Player và Enemy
- [ ] Thêm CollisionShape2D cho tất cả nodes cần
- [ ] Check collision layers đúng
- [ ] Có file `icon.svg` trong root (copy từ Godot default)

---

## 🐛 Troubleshooting

### "Cannot load script at path"
→ Check đường dẫn script trong Inspector

### "Node not found: $Sprite2D"
→ Tên node phải ĐÚNG CHÍNH XÁC như trong `@onready`

### Enemy không gây damage
→ Check collision layers và masks

### Player không di chuyển
→ Đảm bảo Input Actions được setup trong project.godot

---

## 🎯 Bước Tiếp Theo

1. **Tạo placeholder sprites** (ColorRect 32x32)
2. **Test core loop** (di chuyển, spawn enemy, attack)
3. **Thêm XP Gem** và level up system
4. **Thêm UI** hiển thị HP, time, level

**Chúc vui vẻ code!** 🎮
