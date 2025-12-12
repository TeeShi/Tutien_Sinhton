# 🎮 Phân Tích Hệ Thống Chi Tiết: Vampire Survivors
## Áp Dụng Cho Game Tu Tiên Survivors

> **Mục đích:** Phân tích chi tiết từng hệ thống của Vampire Survivors để implement game Tu Tiên
> **Triết lý:** Tôn trọng người chơi, không P2W, giá trị cao - giá thấp
> **Engine đề xuất:** Godot 4 (hoặc Unity)

---

## 📋 Mục Lục

1. [Tổng Quan Kiến Trúc](#1-tổng-quan-kiến-trúc)
2. [Core Loop System](#2-core-loop-system)
3. [Character System](#3-character-system)
4. [Weapon System](#4-weapon-system)
5. [Passive Item System](#5-passive-item-system)
6. [Evolution System](#6-evolution-system)
7. [Enemy System](#7-enemy-system)
8. [XP & Level System](#8-xp--level-system)
9. [Meta Progression System](#9-meta-progression-system)
10. [Stage System](#10-stage-system)
11. [Arcana System](#11-arcana-system)
12. [Technical Implementation](#12-technical-implementation)
13. [Tu Tiên Theme Mapping](#13-tu-tiên-theme-mapping)

---

## 1. Tổng Quan Kiến Trúc

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GAME MANAGER                            │
│  (Singleton - điều phối toàn bộ game state)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  RUN MANAGER  │   │ META MANAGER  │   │  UI MANAGER   │
│ (Per-run state)│   │(Persistent)   │   │ (HUD, Menus)  │
└───────┬───────┘   └───────┬───────┘   └───────────────┘
        │                   │
        ▼                   ▼
┌───────────────────────────────────────┐
│              SUBSYSTEMS               │
├───────────────┬───────────────────────┤
│ • Player      │ • PowerUp Store       │
│ • Weapons     │ • Character Unlocks   │
│ • Enemies     │ • Stage Unlocks       │
│ • Items       │ • Achievement Tracker │
│ • XP/Level    │ • Statistics          │
│ • Timer       │                       │
└───────────────┴───────────────────────┘
```

### Data Flow

```
INPUT (Movement) → PLAYER POSITION → WEAPON TARGETING → DAMAGE → 
ENEMY DEATH → XP DROP → XP COLLECT → LEVEL UP → CHOICE → BUILD GROWS
```

---

## 2. Core Loop System

### Vòng Lặp Chính (30 phút)

```
┌─────────────────────────────────────────────────────────────────┐
│                     CORE GAMEPLAY LOOP                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   START RUN                                                     │
│       │                                                         │
│       ▼                                                         │
│   ┌─────────────────────────────────────────┐                   │
│   │           SURVIVAL LOOP                 │◄─────────┐        │
│   │  ┌─────────────────────────────────┐    │          │        │
│   │  │ 1. Player moves (INPUT)         │    │          │        │
│   │  │ 2. Weapons auto-fire (TICK)     │    │          │        │
│   │  │ 3. Enemies spawn (WAVE)         │    │          │        │
│   │  │ 4. Damage calculation           │    │          │        │
│   │  │ 5. XP gems drop                 │    │          │        │
│   │  │ 6. Player collects gems         │    │          │        │
│   │  └─────────────────────────────────┘    │          │        │
│   └──────────────────┬──────────────────────┘          │        │
│                      │                                 │        │
│                      ▼                                 │        │
│              XP >= THRESHOLD?                          │        │
│                 │         │                            │        │
│              NO │         │ YES                        │        │
│                 │         ▼                            │        │
│                 │    ┌────────────┐                    │        │
│                 │    │ LEVEL UP   │                    │        │
│                 │    │ Choose 1/3 │                    │        │
│                 │    │  options   │                    │        │
│                 │    └─────┬──────┘                    │        │
│                 │          │                           │        │
│                 └──────────┼───────────────────────────┘        │
│                            │                                    │
│                            ▼                                    │
│                    TIME >= 30 MIN?                              │
│                       │         │                               │
│                    NO │         │ YES                           │
│                       │         ▼                               │
│                       │    DEATH SPAWNS                         │
│                       │         │                               │
│                       │         ▼                               │
│                       │    RUN ENDS                             │
│                       │         │                               │
│                       └────►    ▼                               │
│                         COLLECT GOLD                            │
│                              │                                  │
│                              ▼                                  │
│                      META PROGRESSION                           │
│                              │                                  │
│                              ▼                                  │
│                         NEXT RUN                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Timing Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `RUN_DURATION` | 30 minutes | Tổng thời gian 1 run |
| `BOSS_INTERVAL` | 10, 12, 15, 20, 25 min | Thời điểm boss spawn |
| `WAVE_INTERVAL` | 30 seconds | Tăng difficulty |
| `SPAWN_RATE` | Variable | Tăng theo thời gian |
| `DEATH_SPAWN_TIME` | 30:00 | Reaper xuất hiện |

### Tu Tiên Mapping

| VS Concept | Tu Tiên Equivalent |
|------------|-------------------|
| 30 min run | 1 Tiểu Kiếp (Small Tribulation) |
| Death/Reaper | Thiên Lôi (Heavenly Thunder) |
| Boss waves | Yêu Thú Boss / Ma Tu invaders |

---

## 3. Character System

### Character Data Structure

```
CHARACTER {
    id: string
    name: string
    sprite: texture
    
    // Starting equipment
    starting_weapon: WeaponID
    
    // Base stats
    base_stats: {
        max_hp: float          // default 100
        recovery: float        // HP/s, default 0
        armor: int             // damage reduction
        move_speed: float      // default 1.0
        might: float           // damage multiplier, default 1.0
        area: float            // AoE multiplier, default 1.0
        speed: float           // projectile speed, default 1.0
        duration: float        // effect duration, default 1.0
        amount: int            // extra projectiles, default 0
        cooldown: float        // cooldown reduction, default 1.0
        luck: float            // crit/drop chance, default 1.0
        growth: float          // XP multiplier, default 1.0
        greed: float           // gold multiplier, default 1.0
        magnet: float          // pickup radius, default 1.0
        curse: float           // enemy buff (risk/reward), default 1.0
    }
    
    // Passive ability
    passive: {
        stat: StatType
        value_per_level: float
        description: string
    }
    
    // Unlock condition
    unlock: {
        type: "default" | "achievement" | "secret"
        requirement: string
    }
}
```

### Character Examples

| Character | Starting Weapon | Passive | Tu Tiên Equivalent |
|-----------|-----------------|---------|-------------------|
| Antonio | Whip | +10% Might/level | Kiếm Tu (Sword Cultivator) |
| Imelda | Magic Wand | +10% XP/level | Linh Căn (Spirit Root) |
| Gennaro | Knife | +1 Projectile | Ám Khí Sư (Hidden Weapon) |
| Arca | Fire Wand | -15% Cooldown | Luyện Đan Sư (Alchemist) |
| Porta | Lightning Ring | +30% Area | Lôi Tu (Lightning) |
| Mortaccio | Bone | +1 Proj/20 levels | Thi Tu (Corpse Cultivator) |

### Tu Tiên Characters

```
┌──────────────────────────────────────────────────────────────────┐
│                     TU TIÊN CHARACTER SYSTEM                     │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  LINH CĂN TYPE (Spirit Root - Starting Passive)                 │
│  ├── Kim (Metal)  → +Damage, Sword/Blade weapons                │
│  ├── Mộc (Wood)   → +HP Regen, Nature/Poison weapons            │
│  ├── Thủy (Water) → +Cooldown, Ice/Water weapons                │
│  ├── Hỏa (Fire)   → +Area, Fire/Explosion weapons               │
│  └── Thổ (Earth)  → +Defense, Shield/Trap weapons               │
│                                                                  │
│  CULTIVATION PATH (Unlockable)                                   │
│  ├── Kiếm Tu     → Focus on Sword techniques                    │
│  ├── Pháp Tu     → Focus on Magic/Spell techniques              │
│  ├── Thể Tu     → Focus on Body/Physical techniques            │
│  ├── Yêu Tu     → Focus on Monster/Beast techniques            │
│  └── Ma Tu      → Focus on Demonic techniques (risky)          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 4. Weapon System

### Weapon Data Structure

```
WEAPON {
    id: string
    name: string
    description: string
    rarity: "common" | "uncommon" | "rare"
    
    // Visual
    icon: texture
    projectile_sprite: texture
    
    // Base stats (Level 1)
    base_damage: float
    base_cooldown: float      // seconds between attacks
    base_area: float          // radius or size
    base_speed: float         // projectile speed
    base_duration: float      // for lingering effects
    base_amount: int          // projectiles per attack
    knockback: float
    pierce: int               // enemies hit before disappearing
    
    // Behavior
    targeting: "nearest" | "random" | "around_player" | "direction"
    projectile_type: "straight" | "orbit" | "area" | "homing" | "chain"
    
    // Upgrades (8 levels)
    upgrades: [
        { level: 2, bonus: "+1 amount" },
        { level: 3, bonus: "+20% damage" },
        { level: 4, bonus: "+1 pierce" },
        { level: 5, bonus: "+20% area" },
        { level: 6, bonus: "+1 amount" },
        { level: 7, bonus: "+20% damage" },
        { level: 8, bonus: "+1 amount" }
    ]
    
    // Evolution
    evolution: {
        required_passive: PassiveID
        evolved_weapon: WeaponID
    }
}
```

### Weapon Types & Behaviors

```
┌─────────────────────────────────────────────────────────────────┐
│                      WEAPON ARCHETYPES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. PROJECTILE (Straight Line)                                  │
│     ├── Knife: Fast, low damage, high amount                    │
│     ├── Magic Wand: Homing, medium damage                       │
│     └── Runetracer: Bouncing, fills screen                      │
│                                                                 │
│  2. MELEE (Around Player)                                       │
│     ├── Whip: Horizontal sweep                                  │
│     ├── Garlic: Aura damage zone                                │
│     └── King Bible: Orbiting projectiles                        │
│                                                                 │
│  3. AREA (AoE)                                                  │
│     ├── Fire Wand: Random position explosions                   │
│     ├── Lightning Ring: Random position strikes                 │
│     └── Santa Water: Damaging zones                             │
│                                                                 │
│  4. SPECIAL                                                     │
│     ├── Axe: Arc trajectory                                     │
│     ├── Cross: Boomerang                                        │
│     └── Pentagram: Screen clear (rare)                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Tu Tiên Weapons

| VS Weapon | Tu Tiên Equivalent | Element | Description |
|-----------|-------------------|---------|-------------|
| Whip | Phi Kiếm (Flying Sword) | Kim | Kiếm bay chém ngang |
| Magic Wand | Linh Đạn (Spirit Bullet) | Thủy | Đạn truy hồn |
| Knife | Phi Tiêu (Flying Dart) | Kim | Nhiều tiêu nhỏ |
| Axe | Nguyệt Nha (Moon Blade) | Kim | Cung vòng cung |
| Cross | Kiếm Khí (Sword Qi) | Kim | Bay đi bay lại |
| King Bible | Bát Quái Trận (Bagua Formation) | Thổ | Quay quanh người |
| Fire Wand | Hỏa Cầu (Fireball) | Hỏa | Nổ random |
| Garlic | Hộ Thể Công (Body Shield) | Thổ | Aura sát thương |
| Santa Water | Băng Trận (Ice Field) | Thủy | Vùng đóng băng |
| Lightning Ring | Lôi Kích (Thunder Strike) | Kim | Sét random |
| Pentagram | Thiên La Địa Võng | - | Xóa màn hình |
| Bone | Bạch Cốt Trảo (Bone Claw) | - | Ma đạo |

---

## 5. Passive Item System

### Passive Data Structure

```
PASSIVE_ITEM {
    id: string
    name: string
    icon: texture
    max_level: int            // usually 5
    
    // Stat modification
    stat_bonuses: [
        {
            stat: StatType,
            value_per_level: float,
            is_percentage: boolean
        }
    ]
    
    // For evolution
    evolves_weapon: WeaponID | null
}
```

### All Passives & Effects

```
┌─────────────────────────────────────────────────────────────────┐
│                     PASSIVE ITEM TREE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  OFFENSIVE                                                      │
│  ├── Spinach     : +10% Might × 5 = +50% Damage                │
│  ├── Bracer      : +10% Speed × 5 = +50% Projectile Speed      │
│  ├── Candelabrador: +10% Area × 5 = +50% AoE Size              │
│  ├── Duplicator  : +1 Amount × 2 = +2 Projectiles              │
│  └── Crown       : +8% Growth × 5 = +40% XP Gain               │
│                                                                 │
│  DEFENSIVE                                                      │
│  ├── Armor       : +1 Armor × 3 = 3 Damage Reduction           │
│  ├── Hollow Heart: +20% MaxHP × 5 = +100% HP                   │
│  ├── Pummarola   : +0.2 Regen × 5 = 1.0 HP/s                   │
│  └── Tiramisu    : +1 Revival × 1 = Revive once                │
│                                                                 │
│  UTILITY                                                        │
│  ├── Empty Tome  : -8% Cooldown × 5 = -40% CD                  │
│  ├── Spellbinder : +10% Duration × 5 = +50% Duration           │
│  ├── Wings       : +10% MoveSpeed × 5 = +50% Speed             │
│  ├── Attractorb  : +50% Magnet × 2 = +100% Pickup Radius       │
│  ├── Clover      : +10% Luck × 5 = +50% Luck                   │
│  └── Stone Mask  : +10% Greed × 5 = +50% Gold                  │
│                                                                 │
│  SPECIAL                                                        │
│  └── Curse       : +10% × 5 = Enemies stronger but more XP     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Tu Tiên Passives

| VS Passive | Tu Tiên Equivalent | Effect |
|------------|-------------------|--------|
| Spinach | Kim Cương Thể (Diamond Body) | +Sát thương |
| Hollow Heart | Linh Thạch Hộ Tâm | +Max HP |
| Empty Tome | Thái Ất Thần Công | -Cooldown |
| Wings | Ngự Phong Thuật | +Tốc độ di chuyển |
| Bracer | Gia Tốc Phù | +Tốc độ projectile |
| Clover | Khí Vận Đan | +May mắn |
| Crown | Khai Ngộ Đan | +XP gain |
| Duplicator | Phân Thân Thuật | +Số projectile |
| Candelabrador | Thiên La Địa Võng | +AoE |
| Pummarola | Hồi Xuân Đan | +HP regen |
| Armor | Kim Chung Tráo | +Armor |
| Attractorb | Hấp Tinh Đại Pháp | +Pickup radius |

---

## 6. Evolution System

### Evolution Mechanics

```
┌─────────────────────────────────────────────────────────────────┐
│                     EVOLUTION SYSTEM                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CONDITIONS FOR EVOLUTION:                                      │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ 1. Weapon at MAX LEVEL (usually 8)                     │     │
│  │ 2. Required PASSIVE ITEM in inventory                  │     │
│  │ 3. Kill a BOSS enemy (appears at min 10, 12, 15, etc)  │     │
│  │ 4. Open the CHEST dropped by boss                      │     │
│  └────────────────────────────────────────────────────────┘     │
│                                                                 │
│  EVOLUTION FORMULA:                                             │
│                                                                 │
│    ┌──────────┐     ┌──────────┐     ┌──────────────────┐       │
│    │ Weapon   │  +  │ Passive  │  =  │ Evolved Weapon   │       │
│    │ (Lv.Max) │     │ (Any Lv) │     │ (Super Powerful) │       │
│    └──────────┘     └──────────┘     └──────────────────┘       │
│                                                                 │
│  EXAMPLE:                                                       │
│    Whip (Lv 8) + Hollow Heart → Bloody Tear (Lifesteal)        │
│                                                                 │
│  DESIGN INSIGHT:                                                │
│    • Creates PUZZLE layer - plan build from start              │
│    • Passive choice matters even if stat is not ideal          │
│    • Encourages EXPERIMENTATION                                 │
│    • Rewards KNOWLEDGE of combinations                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Complete Evolution Table

| Weapon | + Passive | = Evolved | Effect Change |
|--------|-----------|-----------|---------------|
| Whip | Hollow Heart | Bloody Tear | +Lifesteal |
| Magic Wand | Empty Tome | Holy Wand | No cooldown |
| Knife | Bracer | Thousand Edge | Massive barrage |
| Axe | Candelabrador | Death Spiral | Huge spinning axe |
| Cross | Clover | Heaven Sword | Homing crosses |
| King Bible | Spellbinder | Unholy Vespers | Never disappears |
| Fire Wand | Spinach | Hellfire | Chain explosions |
| Garlic | Pummarola | Soul Eater | Steals enemy HP |
| Santa Water | Attractorb | La Borra | Follows player |
| Lightning | Duplicator | Thunder Loop | Chain lightning |
| Pentagram | Crown | Gorgeous Moon | Bigger, more often |
| Peachone | Ebony Wings | Vandalier | Union (2→1) |
| Phiera Der | Eight Sparrow | Phieraggi | Mega laser |
| Gatti Amari | Stone Mask | Vicious Hunger | Gold on kill |
| Song of Mana | Skull O'Maniac | Mannajja | Slow + damage zone |

### Tu Tiên Evolutions

```
┌─────────────────────────────────────────────────────────────────┐
│                 TU TIÊN EVOLUTION (ĐỘT PHÁ)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  FORMULA:                                                       │
│  Pháp Thuật (Lv.Max) + Đan Dược = Thần Thông                   │
│                                                                 │
│  EXAMPLES:                                                      │
│                                                                 │
│  Phi Kiếm + Kim Cương Thể → Vạn Kiếm Quy Tông                  │
│    (Flying Sword + Diamond Body = Sword Rain)                   │
│                                                                 │
│  Lôi Kích + Phân Thân → Thiên Lôi Vạn Kích                     │
│    (Thunder + Clone = Heaven Thunder Storm)                     │
│                                                                 │
│  Hỏa Cầu + Gia Tốc Phù → Tiêu Dao Hỏa Hải                      │
│    (Fireball + Speed = Fire Sea)                                │
│                                                                 │
│  Hộ Thể Công + Hồi Xuân Đan → Bất Tử Kim Thân                  │
│    (Shield + Regen = Immortal Body)                             │
│                                                                 │
│  Bát Quái Trận + Thiên La Địa Võng → Thái Cực Luân Hồi         │
│    (Bagua + Area = Taichi Cycle)                                │
│                                                                 │
│  NARRATIVE:                                                     │
│  Evolution = "Đột Phá" (Breakthrough)                           │
│  Kết hợp công pháp + ngoại vật → Thăng cấp thần thông          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. Enemy System

### Enemy Data Structure

```
ENEMY {
    id: string
    name: string
    sprite: texture
    
    // Stats
    hp: float
    damage: float
    speed: float
    knockback_resist: float
    
    // Behavior
    ai_type: "chase" | "swarm" | "ranged" | "stationary"
    
    // Drops
    xp_value: int
    gold_value: int
    drop_table: [{ item: ItemID, chance: float }]
    
    // Spawn config
    spawn_weight: float       // relative frequency
    min_time: float           // earliest spawn time (minutes)
    group_size: range         // e.g., 5-10
}
```

### Enemy Types

```
┌─────────────────────────────────────────────────────────────────┐
│                       ENEMY ARCHETYPES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SWARM (90% of enemies)                                         │
│  ├── Low HP, Low Damage                                         │
│  ├── Slow to Medium speed                                       │
│  ├── Appear in LARGE groups                                     │
│  └── Purpose: Screen filling, XP fodder                         │
│                                                                 │
│  ELITE (8% of enemies)                                          │
│  ├── Medium HP, Medium Damage                                   │
│  ├── Medium speed                                               │
│  ├── Appear in small groups                                     │
│  └── Purpose: Pressure, mini-challenge                          │
│                                                                 │
│  BOSS (2% of enemies)                                           │
│  ├── High HP, High Damage                                       │
│  ├── Slow but dangerous                                         │
│  ├── Spawn at timed intervals                                   │
│  ├── Drop TREASURE CHESTS                                       │
│  └── Purpose: Evolution trigger, milestone                      │
│                                                                 │
│  DEATH (End-game)                                               │
│  ├── Infinite HP                                                │
│  ├── Instakill damage                                           │
│  ├── Very fast                                                  │
│  └── Purpose: End the run at 30 min                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Spawn Wave System

```
TIME      ENEMY COMPOSITION
0:00      Basic swarm only
2:00      +Elite type 1
5:00      +Swarm type 2, +Elite type 2
8:00      +Ranged enemies
10:00     BOSS 1 + chest
12:00     BOSS 2 + increased swarm density
15:00     BOSS 3 + all enemy types
20:00     BOSS 4 + maximum density
25:00     BOSS 5 + elite swarms
30:00     DEATH SPAWNS - run ends
```

### Tu Tiên Enemies

| Type | VS Equivalent | Tu Tiên Version |
|------|--------------|-----------------|
| Swarm | Bats, Skeletons | Yêu Trùng (Demon Insects) |
| Swarm+ | Ghosts, Mummies | Oan Hồn (Vengeful Spirits) |
| Elite | Witches, Werewolves | Yêu Thú (Demon Beasts) |
| Elite+ | Giant enemies | Ma Tu Đệ Tử (Demon Disciples) |
| Boss | Drowners, Stalkers | Yêu Vương (Demon King) |
| Death | Reaper | Thiên Lôi (Heavenly Tribulation) |

---

## 8. XP & Level System

### XP Mechanics

```
┌─────────────────────────────────────────────────────────────────┐
│                      XP & LEVEL SYSTEM                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  XP GEMS                                                        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Blue Gem    = 1 XP   (common enemies)                  │    │
│  │  Green Gem   = 3 XP   (elite enemies)                   │    │
│  │  Red Gem     = 7 XP   (boss enemies)                    │    │
│  │  White Gem   = Scale  (varies by enemy level)           │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  COLLECTION                                                     │
│  • Gems move TOWARD player                                      │
│  • Base pickup radius: ~50 pixels                               │
│  • Magnet stat increases radius                                 │
│  • Vacuum item: Collect ALL gems on screen                      │
│                                                                 │
│  LEVEL UP                                                       │
│  • XP threshold increases per level                             │
│  • Formula: XP_needed = base + (level × multiplier)             │
│  • Example: 5, 10, 20, 40, 65, 95, 130, 170...                  │
│                                                                 │
│  LEVEL UP CHOICE                                                │
│  • Show 3-4 options                                             │
│  • Options: New weapon, weapon upgrade, new passive, upgrade    │
│  • Weight by RARITY and LUCK stat                               │
│  • REROLL: Spend currency to get new options                    │
│  • SKIP: Remove unwanted option permanently                     │
│  • BANISH: Remove from future options entirely                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Level Up Pool Logic

```
GENERATE_LEVEL_UP_OPTIONS(player, count=3):
    pool = []
    
    # Add weapons
    if player.weapon_slots < 6:
        for weapon in ALL_WEAPONS:
            if weapon not in player.weapons:
                if weapon not in player.banished:
                    pool.add(WeaponNew(weapon))
    
    # Add weapon upgrades
    for weapon in player.weapons:
        if weapon.level < weapon.max_level:
            pool.add(WeaponUpgrade(weapon))
    
    # Add passives
    if player.passive_slots < 6:
        for passive in ALL_PASSIVES:
            if passive not in player.passives:
                if passive not in player.banished:
                    pool.add(PassiveNew(passive))
    
    # Add passive upgrades
    for passive in player.passives:
        if passive.level < passive.max_level:
            pool.add(PassiveUpgrade(passive))
    
    # Weight by rarity and luck
    weighted_pool = apply_rarity_weights(pool, player.luck)
    
    # Select random options
    return random.sample(weighted_pool, min(count, len(pool)))
```

### Tu Tiên XP/Level

| VS Concept | Tu Tiên Equivalent |
|------------|-------------------|
| XP Gems | Linh Thạch (Spirit Stones) |
| Level Up | Đột Phá Cảnh Giới |
| Choose option | Ngộ Đạo (Enlightenment) |
| Reroll | Dùng Linh Thạch đổi cơ duyên |
| Banish | Phong Ấn Công Pháp |

---

## 9. Meta Progression System

### PowerUp Store

```
┌─────────────────────────────────────────────────────────────────┐
│                    META PROGRESSION                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  GOLD COLLECTION                                                │
│  • Enemies drop gold coins                                      │
│  • Gold persists between runs                                   │
│  • Gold spent on PERMANENT upgrades                             │
│                                                                 │
│  POWERUP STORE                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  PowerUp        │ Max │ Cost/Lv │ Effect/Lv            │    │
│  │  ──────────────────────────────────────────────────────│    │
│  │  Might          │  5  │   200   │ +5% Damage           │    │
│  │  Armor          │  3  │   600   │ +1 Armor             │    │
│  │  Max Health     │  3  │   200   │ +10% HP              │    │
│  │  Recovery       │  5  │   200   │ +0.1 HP/s            │    │
│  │  Cooldown       │  2  │   900   │ -2.5% CD             │    │
│  │  Area           │  2  │   300   │ +5% Area             │    │
│  │  Speed          │  2  │   300   │ +5% Proj Speed       │    │
│  │  Duration       │  2  │   300   │ +7.5% Duration       │    │
│  │  Amount         │  1  │  5000   │ +1 Projectile        │    │
│  │  MoveSpeed      │  2  │   300   │ +5% Move Speed       │    │
│  │  Magnet         │  2  │   300   │ +25% Pickup          │    │
│  │  Luck           │  3  │   600   │ +10% Luck            │    │
│  │  Growth         │  5  │   300   │ +3% XP               │    │
│  │  Greed          │  5  │   200   │ +10% Gold            │    │
│  │  Curse          │  5  │   166   │ +10% Enemy Buff      │    │
│  │  Revival        │  3  │ 10000   │ +1 Revive/Run        │    │
│  │  Skip           │  5  │   100   │ +1 Skip/Run          │    │
│  │  Banish         │  5  │   100   │ +1 Banish/Run        │    │
│  │  Reroll         │  5  │   100   │ +1 Reroll/Run        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  SPECIAL: Can REFUND all PowerUps at no cost!                   │
│  (Encourages experimentation)                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Unlock System

```
UNLOCKABLES:
├── Characters (Achievement-based)
│   ├── "Kill 100 enemies" → Unlock X
│   ├── "Survive 15 min" → Unlock Y
│   └── "Collect 1000 gold in one run" → Unlock Z
│
├── Stages (Achievement-based)
│   ├── "Reach level 20" → Unlock Stage 2
│   ├── "Kill boss in Stage 1" → Unlock Stage 3
│   └── "Find secret item" → Unlock Hidden Stage
│
├── Weapons (Character/Stage-based)
│   ├── Start with Character X → Weapon available
│   └── Find in Stage Y → Weapon added to pool
│
├── Arcanas (Level/Time-based)
│   ├── "Reach level 50" → Arcana I
│   └── "Survive 25 min" → Arcana II
│
└── Secrets
    ├── Hidden characters in stages
    ├── Secret weapon combinations
    └── Easter eggs
```

### Tu Tiên Meta Progression

| VS Concept | Tu Tiên Equivalent |
|------------|-------------------|
| Gold | Linh Thạch (Spirit Stones) |
| PowerUps | Cố Định Tu Vi (Fixed Cultivation) |
| Character Unlock | Thu Đồ Đệ (Recruit Disciple) |
| Stage Unlock | Khai Mở Bí Cảnh (Open Secret Realm) |
| Refund | Tẩy Cốt Đan (Bone Cleansing Pill) |

---

## 10. Stage System

### Stage Data Structure

```
STAGE {
    id: string
    name: string
    
    // Visual
    tileset: texture
    background: texture
    palette: ColorPalette
    
    // Layout
    size: "infinite" | { width: int, height: int }
    scroll_type: "free" | "horizontal" | "vertical"
    
    // Enemies
    enemy_pool: [
        { enemy: EnemyID, weight: float, min_time: float }
    ]
    boss_schedule: [
        { boss: EnemyID, time: float }
    ]
    
    // Special objects
    interactables: [
        { type: "chest" | "brazier" | "rosary" | "vacuum", spawn_rule: ... }
    ]
    
    // Stage items (unique weapons found here)
    stage_items: [WeaponID]
    
    // Modes
    hyper_unlocked: boolean     // faster but more rewarding
    hurry_unlocked: boolean     // 2x speed clock
    inverse_unlocked: boolean   // modified rules
}
```

### Stage Examples

| Stage | Theme | Special | Tu Tiên Version |
|-------|-------|---------|-----------------|
| Mad Forest | Forest | Balanced, default | Thái Cực Lâm (Taichi Forest) |
| Inlaid Library | Books | Narrow corridors | Tàng Kinh Các (Scripture Pavilion) |
| Dairy Plant | Factory | Long horizontal | Luyện Đan Phòng (Alchemy Hall) |
| Gallo Tower | Castle | Vertical scroll | Vạn Yêu Tháp (Demon Tower) |
| Cappella Magna | Church | Secret boss | Hồn Thiên Điện (Heaven Soul Hall) |
| Moongolow | Night | All weapons appear | Vọng Nguyệt Đỉnh (Moon Peak) |
| Holy Forbidden | Final | Ultimate challenge | Tuyệt Địa (Forbidden Zone) |

---

## 11. Arcana System

### Arcana Mechanics

```
┌─────────────────────────────────────────────────────────────────┐
│                      ARCANA SYSTEM                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  WHAT: Global modifiers that change gameplay rules              │
│  WHEN: Choose at 0:00 (optional), unlock slots at levels        │
│  HOW: Pick from unlocked arcanas, effects last entire run       │
│                                                                 │
│  UNLOCK CONDITIONS:                                             │
│  ├── Reach certain levels in a run                              │
│  ├── Survive specific times                                     │
│  ├── Complete specific achievements                             │
│  └── Find in stages                                             │
│                                                                 │
│  EXAMPLES:                                                      │
│  ┌────────────────────────────────────────────────────────┐     │
│  │  I   Game Killer    : Area +100%, All become AoE       │     │
│  │  II  Twilight       : Cooldown -50%, Might +50%        │     │
│  │  III Tragic Princess: Weapons fire when moving         │     │
│  │  IV  Awake          : Revive with +30% HP each time    │     │
│  │  VII Iron Blue Will : Retaliator evolves automatically │     │
│  │  X   Beginning      : Start with 3 items               │     │
│  │  XVI Slash          : +50% Crit Damage                 │     │
│  └────────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Tu Tiên Arcanas (Thiên Mệnh)

| Arcana | Tu Tiên Name | Effect |
|--------|-------------|--------|
| Game Killer | Vạn Pháp Quy Nhất | All attacks become AoE |
| Twilight | Âm Dương Điên Đảo | -CD, +Damage |
| Awake | Bất Tử Thân | Revive stronger |
| Beginning | Thiên Sinh Kỳ Tài | Start with extra skills |
| Slash | Sát Thần Chi Mệnh | +Crit damage |
| Blood Astronomia | Huyết Thần Chi Đạo | Damage scales with Curse |

---

## 12. Technical Implementation

### Key Technical Patterns

```
┌─────────────────────────────────────────────────────────────────┐
│                 TECHNICAL ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. OBJECT POOLING (Critical for performance)                   │
│     ├── Enemy Pool: Pre-allocate 500-1000 enemies               │
│     ├── Projectile Pool: Pre-allocate 200-500 projectiles       │
│     ├── XP Gem Pool: Pre-allocate 1000+ gems                    │
│     └── VFX Pool: Pre-allocate 100+ effects                     │
│                                                                 │
│  2. SPATIAL PARTITIONING                                        │
│     ├── Grid-based for collision detection                      │
│     ├── Only check nearby cells                                 │
│     └── Critical when 1000+ entities on screen                  │
│                                                                 │
│  3. ENTITY COMPONENT SYSTEM (Optional but helpful)              │
│     ├── Separate data from behavior                             │
│     ├── Easy to add/remove components                           │
│     └── Better cache performance                                │
│                                                                 │
│  4. TIMER/COOLDOWN SYSTEM                                       │
│     ├── Central timer manager                                   │
│     ├── Weapons register cooldowns                              │
│     └── Events fire when ready                                  │
│                                                                 │
│  5. STAT CALCULATION                                            │
│     ├── Base stat + PowerUp + Passive + Character bonus         │
│     ├── Cache calculated values                                 │
│     └── Recalculate on level up / item change                   │
│                                                                 │
│  6. PSEUDO-RANDOM (Drop fairness)                               │
│     ├── Pity system for rare drops                              │
│     └── Prevent bad luck streaks                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Godot 4 Implementation Notes

```gdscript
# Stat calculation example
func calculate_final_stat(base_stat: String) -> float:
    var base = character.base_stats[base_stat]
    var powerup = meta_manager.get_powerup_bonus(base_stat)
    var passive = get_passive_bonus(base_stat)
    var character_bonus = character.passive_bonus if character.passive_stat == base_stat else 0
    
    return base * (1 + powerup + passive + character_bonus)

# Object pooling example
class_name EnemyPool
var pool: Array[Enemy] = []
var active: Array[Enemy] = []

func get_enemy() -> Enemy:
    if pool.is_empty():
        return Enemy.new()  # Expand pool
    var enemy = pool.pop_back()
    active.append(enemy)
    return enemy

func release_enemy(enemy: Enemy):
    active.erase(enemy)
    enemy.reset()
    pool.append(enemy)
```

---

## 13. Tu Tiên Theme Mapping

### Complete Theme Translation

```
┌─────────────────────────────────────────────────────────────────┐
│                    TU TIÊN THEME MAPPING                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CORE CONCEPTS                                                  │
│  ├── Vampire Survivors → Tu Tiên Sinh Tồn (Cultivation Survival)│
│  ├── Run = 30 min → Tiểu Thiên Kiếp (Small Heavenly Tribulation)│
│  ├── Death/Reaper → Thiên Lôi (Heavenly Thunder)                │
│  └── Survive → Độ Kiếp Thành Công (Pass Tribulation)            │
│                                                                 │
│  PLAYER                                                         │
│  ├── Character → Tu Sĩ (Cultivator)                             │
│  ├── Level Up → Đột Phá (Breakthrough)                          │
│  ├── HP → Tu Vi (Cultivation Base)                              │
│  └── Gold → Linh Thạch (Spirit Stones)                          │
│                                                                 │
│  COMBAT                                                         │
│  ├── Weapons → Công Pháp (Techniques)                           │
│  ├── Passives → Đan Dược (Pills/Elixirs)                        │
│  ├── Evolution → Thần Thông (Divine Power)                      │
│  └── Damage → Sát Thương                                        │
│                                                                 │
│  ENEMIES                                                        │
│  ├── Swarm → Yêu Trùng (Demon Insects)                          │
│  ├── Elite → Yêu Thú (Demon Beasts)                             │
│  ├── Boss → Yêu Vương (Demon Kings)                             │
│  └── Death → Thiên Lôi (Heaven's Wrath)                         │
│                                                                 │
│  PROGRESSION                                                    │
│  ├── XP Gems → Linh Khí (Spirit Energy)                         │
│  ├── PowerUps → Cố Định Tu Vi (Permanent Cultivation)           │
│  ├── Arcanas → Thiên Mệnh (Heavenly Fate)                       │
│  └── Stages → Bí Cảnh (Secret Realms)                           │
│                                                                 │
│  ELEMENTS                                                       │
│  ├── Fire damage → Hỏa Hệ                                       │
│  ├── Ice damage → Thủy Hệ                                       │
│  ├── Lightning → Lôi Hệ (Kim)                                   │
│  ├── Poison → Mộc Hệ                                            │
│  └── Physical → Thể Tu                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Visual Style Recommendations

| Element | VS Style | Tu Tiên Style |
|---------|----------|---------------|
| Palette | Gothic, dark purple/red | Eastern, jade/gold/cyan |
| Art | Pixel art | Ink wash / Pixel hybrid |
| UI | Simple gothic | Scroll/bamboo frames |
| Effects | Blood, skulls | Qi flow, Taichi symbols |
| Music | Retro 8-bit | Traditional Chinese mix |

---

## Kết Luận

Với các hệ thống đã phân tích, bạn có đủ foundation để xây dựng **Tu Tiên Survivors**:

### Checklist Implementation

- [ ] Core Loop (30 min timer, waves, boss schedule)
- [ ] Character System (5 Linh Căn types)
- [ ] Weapon System (12+ Công Pháp)
- [ ] Passive System (12+ Đan Dược)
- [ ] Evolution System (weapon + passive = thần thông)
- [ ] Enemy System (swarm, elite, boss, death)
- [ ] XP/Level System (gems, choices, reroll/skip/banish)
- [ ] Meta Progression (PowerUps, unlocks)
- [ ] Stage System (5+ Bí Cảnh)
- [ ] Arcana System (10+ Thiên Mệnh)

### Next Steps

1. **Prototype Core Loop** - Movement + 1 weapon + enemies
2. **Add Level Up** - XP gems + choice system
3. **Expand Weapons** - 3-4 weapon types
4. **Add Evolution** - 2-3 evolutions
5. **Meta Layer** - Gold + PowerUps
6. **Polish** - VFX, sound, juice

---

*Phân tích chi tiết được thực hiện ngày: 12/12/2024*
*Project: Tu Tiên Survivors*
