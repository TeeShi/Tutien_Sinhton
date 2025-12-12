# 👹 Hệ Thống Kẻ Địch (Enemies)

← [[00_Home|Quay lại Home]]

---

## Tổng Quan

Yêu Ma trong Tu Tiên Sinh Tồn được chia thành 4 cấp độ chính, từ Yêu Trùng nhỏ bé đến Thiên Lôi hủy diệt.

---

## Phân Loại Kẻ Địch

```
┌─────────────────────────────────────────────────────────────────┐
│                       ENEMY HIERARCHY                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐                                               │
│   │ THIÊN LÔI   │  ← Instant kill, ends run at 30:00           │
│   │  (Death)    │                                               │
│   └──────┬──────┘                                               │
│          │                                                      │
│   ┌──────┴──────┐                                               │
│   │  YÊU VƯƠNG  │  ← High HP, drops treasure chest              │
│   │   (Boss)    │     Spawns at 10, 12, 15, 20, 25 min         │
│   └──────┬──────┘                                               │
│          │                                                      │
│   ┌──────┴──────┐                                               │
│   │  YÊU THÚ    │  ← Medium HP, dangerous                       │
│   │  (Elite)    │     8% of spawns                              │
│   └──────┬──────┘                                               │
│          │                                                      │
│   ┌──────┴──────┐                                               │
│   │  YÊU TRÙNG  │  ← Low HP, XP fodder                          │
│   │  (Swarm)    │     90% of spawns                             │
│   └─────────────┘                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🐛 Yêu Trùng (Swarm Enemies)

Yêu Trùng là loại địch phổ biến nhất, xuất hiện thành đàn lớn. Mục đích: tạo áp lực liên tục và cung cấp Linh Khí.

### Danh Sách Yêu Trùng

#### Tiểu Yêu Trùng - Basic Insect
| Stat | Value |
|------|-------|
| **HP** | 5 |
| **Damage** | 5 |
| **Speed** | Slow |
| **XP** | 1 (Blue gem) |
| **Spawn** | 0:00+ |

> *Loại yêu cơ bản nhất, sinh sôi vô hạn.*

---

#### Yêu Bướm - Demon Butterfly
| Stat | Value |
|------|-------|
| **HP** | 8 |
| **Damage** | 8 |
| **Speed** | Medium |
| **XP** | 1 |
| **Spawn** | 2:00+ |

> *Bay nhanh hơn, khó né.*

---

#### Cương Thi - Zombie
| Stat | Value |
|------|-------|
| **HP** | 15 |
| **Damage** | 10 |
| **Speed** | Slow |
| **XP** | 2 |
| **Spawn** | 3:00+ |

> *Chậm nhưng đông, khó tiêu diệt.*

---

#### Oan Hồn - Vengeful Spirit
| Stat | Value |
|------|-------|
| **HP** | 10 |
| **Damage** | 12 |
| **Speed** | Fast |
| **XP** | 2 |
| **Spawn** | 5:00+ |
| **Special** | Phasing (xuyên qua objects) |

> *Xuyên tường, khó chạy trốn.*

---

#### Huyết Bức - Blood Bat
| Stat | Value |
|------|-------|
| **HP** | 8 |
| **Damage** | 8 |
| **Speed** | Very Fast |
| **XP** | 1 |
| **Spawn** | 7:00+ |

> *Cực nhanh, xuất hiện thành đàn lớn.*

---

#### Ma Đầu - Demon Head
| Stat | Value |
|------|-------|
| **HP** | 20 |
| **Damage** | 15 |
| **Speed** | Medium |
| **XP** | 3 |
| **Spawn** | 10:00+ |

> *Ma đầu bay lơ lửng, khá mạnh.*

---

### Swarm Behavior

```
SWARM AI:
1. Spawn outside screen (random edge)
2. Move toward player position
3. Recalculate direction every 0.5s
4. On death: drop XP gem, play death VFX
```

---

## 🐺 Yêu Thú (Elite Enemies)

Yêu Thú mạnh hơn, xuất hiện ít hơn nhưng nguy hiểm hơn.

### Danh Sách Yêu Thú

#### Yêu Lang - Demon Wolf
| Stat | Value |
|------|-------|
| **HP** | 50 |
| **Damage** | 20 |
| **Speed** | Fast |
| **XP** | 5 (Green gem) |
| **Spawn** | 5:00+ |
| **Special** | Lunges at player |

---

#### Cự Xà - Giant Serpent
| Stat | Value |
|------|-------|
| **HP** | 80 |
| **Damage** | 25 |
| **Speed** | Medium |
| **XP** | 7 |
| **Spawn** | 8:00+ |
| **Special** | Poison trail |

---

#### Phi Thiên Hổ - Flying Tiger
| Stat | Value |
|------|-------|
| **HP** | 100 |
| **Damage** | 30 |
| **Speed** | Fast |
| **XP** | 10 |
| **Spawn** | 12:00+ |
| **Special** | Pounce attack |

---

#### Ma Tu Đệ Tử - Demon Disciple
| Stat | Value |
|------|-------|
| **HP** | 120 |
| **Damage** | 35 |
| **Speed** | Medium |
| **XP** | 12 |
| **Spawn** | 15:00+ |
| **Special** | Ranged attacks |

---

#### Hắc Long Kỳ - Black Dragon Knight
| Stat | Value |
|------|-------|
| **HP** | 200 |
| **Damage** | 40 |
| **Speed** | Slow |
| **XP** | 20 |
| **Spawn** | 20:00+ |
| **Special** | Armor (reduced damage) |

---

### Elite Behavior

```
ELITE AI:
1. Spawn with warning indicator
2. Track player more accurately
3. Use special abilities
4. Drop larger XP gems
5. Brief invulnerability on spawn
```

---

## 👑 Yêu Vương (Bosses)

Yêu Vương là boss xuất hiện theo thời gian, drop Bảo Rương (treasure chest) để trigger Evolution.

### Boss Schedule

| Time | Boss | HP | Special |
|------|------|-----|---------|
| 10:00 | Bạch Cốt Tinh | 500 | Summons skeletons |
| 12:00 | Cửu Vĩ Hồ | 800 | Fire breath |
| 15:00 | Hắc Long | 1200 | Lightning strikes |
| 20:00 | Thiên Ma | 2000 | Teleports |
| 25:00 | Ma Vương | 3000 | All abilities |

---

### Boss: Bạch Cốt Tinh - Bone Demon

```
┌─────────────────────────────────────────┐
│            BẠCH CỐT TINH               │
│         ░░░▒▒▓▓████▓▓▒▒░░░             │
│        ░░▒▒▓▓██████████▓▓▒▒░░          │
│           ☠ SKULL FACE ☠               │
│              ╔══════╗                   │
│              ║ BOSS ║                   │
│              ╚══════╝                   │
└─────────────────────────────────────────┘
```

| Stat | Value |
|------|-------|
| **HP** | 500 |
| **Damage** | 30 |
| **Speed** | Slow |
| **Abilities** | Summon skeletons, bone throw |
| **Drop** | Treasure Chest (evolution trigger) |

---

### Boss: Cửu Vĩ Hồ - Nine-Tailed Fox

| Stat | Value |
|------|-------|
| **HP** | 800 |
| **Damage** | 40 |
| **Speed** | Fast |
| **Abilities** | Fire breath (cone), illusion clones |
| **Drop** | Treasure Chest |

---

### Boss: Hắc Long - Black Dragon

| Stat | Value |
|------|-------|
| **HP** | 1200 |
| **Damage** | 50 |
| **Speed** | Medium |
| **Abilities** | Lightning AoE, tail swipe |
| **Drop** | Treasure Chest |

---

### Boss: Thiên Ma - Heavenly Demon

| Stat | Value |
|------|-------|
| **HP** | 2000 |
| **Damage** | 60 |
| **Speed** | Variable |
| **Abilities** | Teleport, soul drain, dark wave |
| **Drop** | Treasure Chest |

---

### Boss: Ma Vương - Demon King

| Stat | Value |
|------|-------|
| **HP** | 3000 |
| **Damage** | 80 |
| **Speed** | Slow |
| **Abilities** | ALL previous boss abilities |
| **Drop** | Treasure Chest + bonus loot |

---

## ⚡ Thiên Lôi (Death)

Thiên Lôi là "kết thúc run" entity, xuất hiện lúc 30:00 để end game.

### Thiên Lôi - Heavenly Thunder

| Stat | Value |
|------|-------|
| **HP** | ∞ (Infinite) |
| **Damage** | ∞ (Instant kill) |
| **Speed** | Very Fast |
| **Purpose** | End the run |

```
┌─────────────────────────────────────────┐
│              THIÊN LÔI                 │
│                                         │
│         ⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡         │
│       ⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡       │
│     ⚡⚡⚡ INEVITABLE DEATH ⚡⚡⚡     │
│       ⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡       │
│         ⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡         │
│                                         │
│   "30 phút đã hết, Thiên Lôi giáng!"   │
│                                         │
└─────────────────────────────────────────┘
```

> **Narrative:** Thiên Đạo không cho phép tu sĩ ở quá lâu trong Bí Cảnh. 30 phút là giới hạn, sau đó Thiên Lôi sẽ giáng xuống trừng phạt.

### Secret: Có thể giết Thiên Lôi?

> 🤫 **SECRET:** Với build cực mạnh và item đặc biệt, người chơi CÓ THỂ giết Thiên Lôi để unlock secret character!

---

## Spawn System

### Wave Configuration

| Time | Swarm Density | Elite Rate | Special |
|------|---------------|------------|---------|
| 0-5 min | Low | 0% | Tutorial phase |
| 5-10 min | Medium | 5% | Elites appear |
| 10-15 min | High | 10% | Boss 1,2 |
| 15-20 min | Very High | 15% | Boss 3 |
| 20-25 min | Maximum | 20% | Boss 4 |
| 25-30 min | INSANE | 25% | Boss 5 |
| 30:00 | - | - | THIÊN LÔI |

### Spawn Formula

```gdscript
func calculate_spawn_rate(time: float) -> float:
    var base_rate = 1.0
    var time_multiplier = 1 + (time / 60.0)  # +100% per minute
    var curse_multiplier = 1 + (player.curse * 0.5)
    return base_rate * time_multiplier * curse_multiplier
```

---

## XP Gem Types

| Gem | XP Value | Dropped By |
|-----|----------|------------|
| 🔵 Blue | 1 | Yêu Trùng |
| 🟢 Green | 5 | Yêu Thú |
| 🔴 Red | 25 | Yêu Vương |
| ⚪ White | Variable | Scale enemies |

---

← [[00_Home|Home]] | [[40_Linh_Khi|XP System →]]
