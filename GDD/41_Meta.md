# 📈 Meta Progression System

← [[00_Home|Quay lại Home]]

---

## Tổng Quan

Meta Progression là hệ thống tiến bộ **vĩnh viễn** giữa các lượt chơi. Mỗi run, dù thắng hay thua, đều đóng góp vào sức mạnh tổng thể của người chơi.

### Triết Lý

```
"Mỗi run = progress. Không có run nào là lãng phí."
```

---

## Linh Thạch (Gold)

### Thu Thập

| Source | Amount |
|--------|--------|
| Yêu Trùng | 1-2 |
| Yêu Thú | 5-10 |
| Yêu Vương | 50-100 |
| Treasure Chest | 20-50 |
| Floor pickups | 10-30 |

### Công Thức

```
Final Gold = Base Gold × Greed Multiplier × Stage Bonus
```

---

## Cố Định Tu Vi (PowerUps)

PowerUps là buff vĩnh viễn mua bằng Linh Thạch, apply cho TẤT CẢ các run sau.

### PowerUp Store

```
┌─────────────────────────────────────────────────────────────────┐
│                    CỬA HÀNG TU LUYỆN                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   LỰC       │  │   PHÒNG     │  │   SINH      │             │
│  │   +5%/Lv    │  │   +1/Lv     │  │   +10%/Lv   │             │
│  │   200💎     │  │   600💎     │  │   200💎     │             │
│  │   ★★★☆☆    │  │   ★★★☆☆    │  │   ★★★☆☆    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  [MUA]          [MUA]          [MUA]                           │
│                                                                 │
│  💎 Linh Thạch: 1,250                    [HOÀN TRẢ TẤT CẢ]     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Danh Sách PowerUps

#### Offensive PowerUps

| PowerUp | Max Lv | Cost/Lv | Effect/Lv | Total |
|---------|--------|---------|-----------|-------|
| **Lực (Might)** | 5 | 200 | +5% Damage | +25% |
| **Bội Giảm (Cooldown)** | 2 | 900 | -2.5% CD | -5% |
| **Diện Tích (Area)** | 2 | 300 | +5% Area | +10% |
| **Phi Tốc (Speed)** | 2 | 300 | +5% Proj Speed | +10% |
| **Khí Tức (Duration)** | 2 | 300 | +7.5% Duration | +15% |
| **Số Lượng (Amount)** | 1 | 5000 | +1 Projectile | +1 |

#### Defensive PowerUps

| PowerUp | Max Lv | Cost/Lv | Effect/Lv | Total |
|---------|--------|---------|-----------|-------|
| **Phòng Ngự (Armor)** | 3 | 600 | +1 Armor | +3 |
| **Sinh Lực (Max HP)** | 3 | 200 | +10% HP | +30% |
| **Hồi Phục (Recovery)** | 5 | 200 | +0.1 HP/s | +0.5/s |
| **Phục Sinh (Revival)** | 3 | 10000 | +1 Revive | +3 |

#### Utility PowerUps

| PowerUp | Max Lv | Cost/Lv | Effect/Lv | Total |
|---------|--------|---------|-----------|-------|
| **Di Tốc (MoveSpeed)** | 2 | 300 | +5% Speed | +10% |
| **Hấp Thu (Magnet)** | 2 | 300 | +25% Radius | +50% |
| **Khí Vận (Luck)** | 3 | 600 | +10% Luck | +30% |
| **Ngộ Đạo (Growth)** | 5 | 300 | +3% XP | +15% |
| **Tài Lộc (Greed)** | 5 | 200 | +10% Gold | +50% |

#### Special PowerUps

| PowerUp | Max Lv | Cost/Lv | Effect/Lv | Total |
|---------|--------|---------|-----------|-------|
| **Nghiệp Chướng (Curse)** | 5 | 166 | +10% Enemy Buff | +50% |
| **Hồi Số (Reroll)** | 5 | 100 | +1 Reroll/run | +5 |
| **Bỏ Qua (Skip)** | 5 | 100 | +1 Skip/run | +5 |
| **Phong Ấn (Banish)** | 5 | 100 | +1 Banish/run | +5 |

### Đặc Biệt: HOÀN TRẢ

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOÀN TRẢ (REFUND)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Hoàn trả TẤT CẢ PowerUps về 0 và nhận lại TOÀN BỘ Linh Thạch  │
│                                                                 │
│  Chi phí: MIỄN PHÍ!                                            │
│                                                                 │
│  Mục đích: Khuyến khích thử nghiệm các build khác nhau         │
│                                                                 │
│                        [XÁC NHẬN HOÀN TRẢ]                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

> **Design Note:** Refund miễn phí là key feature để người chơi thử nhiều builds mà không sợ phí Linh Thạch.

---

## Unlock System

### Tu Sĩ Unlocks

| Tu Sĩ | Điều Kiện | Difficulty |
|-------|-----------|------------|
| Kiếm Tiểu Sinh | Default | - |
| Hỏa Linh Nhi | Default | - |
| Thủy Nguyệt | Default | - |
| Lôi Chấn Tử | Kill 3000 enemies | ⭐ |
| Mộc Thanh Y | Survive 20 min | ⭐⭐ |
| Thạch Cương | Take 10000 damage | ⭐⭐ |
| Bạch Cốt | Find Secret Tomb | ⭐⭐⭐ |
| U Hồn | Collect 5000 XP in one run | ⭐⭐ |
| Long Tử | Complete with 5 characters | ⭐⭐⭐ |
| Tử Thần | Kill Thiên Lôi | ⭐⭐⭐⭐⭐ |

### Bí Cảnh Unlocks

| Bí Cảnh | Điều Kiện |
|---------|-----------|
| Thái Cực Lâm | Default |
| Tàng Kinh Các | Reach level 20 |
| Vạn Yêu Tháp | Defeat 1 Boss |
| Hồn Thiên Điện | Survive 25 min |
| Tuyệt Địa | Complete all other stages |

### Công Pháp Unlocks

| Unlock Type | How |
|-------------|-----|
| Starting weapon | Tied to character |
| Stage items | Found in specific stages |
| Achievement items | Complete achievements |
| Secret items | Hidden conditions |

### Thiên Mệnh Unlocks

| Thiên Mệnh | Điều Kiện |
|------------|-----------|
| I - Vạn Pháp Quy Nhất | Reach level 50 |
| II - Âm Dương Điên Đảo | Reach level 100 |
| IV - Bất Tử Thân | Die and revive 3 times |
| X - Thiên Sinh Kỳ Tài | Start with 6 weapons |
| XVI - Sát Thần Chi Mệnh | Deal 1M damage in one run |

---

## Achievements

### Categories

| Category | Count | Focus |
|----------|-------|-------|
| **Tu Luyện** | 20 | Character mastery |
| **Chiến Đấu** | 15 | Combat milestones |
| **Thu Thập** | 10 | Collect items |
| **Khám Phá** | 10 | Find secrets |
| **Đặc Biệt** | 5 | Special challenges |

### Example Achievements

| Achievement | Condition | Reward |
|-------------|-----------|--------|
| Sơ Nhập Giang Hồ | Complete first run | 100💎 |
| Vạn Kiếm Quy Tông | Get first evolution | Unlock hint |
| Bất Bại | Win without taking damage | 500💎 |
| Bách Phát Bách Trúng | Kill 10000 enemies | Unlock character |
| Thăng Tiên | Defeat Thiên Lôi | SECRET |

---

## Statistics Tracking

### Per-Run Stats

| Stat | Description |
|------|-------------|
| Time survived | Duration |
| Enemies killed | Total count |
| Damage dealt | Total damage |
| Damage taken | Total received |
| XP collected | Total XP |
| Gold collected | Total gold |
| Level reached | Final level |
| Evolutions | Count |

### Lifetime Stats

| Stat | Description |
|------|-------------|
| Total runs | All attempts |
| Total time | Hours played |
| Total kills | All enemies |
| Highest level | Record |
| Most damage | In one run |
| Best time | Fastest 30min clear |

---

## Progression Flow

```
     START
        │
        ▼
   ┌─────────┐
   │ RUN #1  │──► Collect gold + unlock progress
   └────┬────┘
        │
        ▼
   ┌─────────────┐
   │ BUY POWERUPS│──► Get stronger
   └──────┬──────┘
          │
          ▼
   ┌─────────────┐
   │ RUN #2      │──► Go further + more unlocks
   └──────┬──────┘
          │
          ▼
   ┌─────────────┐
   │ MORE POWER  │──► Even stronger
   └──────┬──────┘
          │
          ▼
   ┌─────────────┐
   │ MASTERY!    │──► Complete all content
   └─────────────┘
```

### Design Goal

```
Run 1: Survive 5 min, learn basics
Run 5: Survive 15 min, get first evolution
Run 10: Survive 25 min, almost win
Run 15: Win first time!
Run 50: Try different builds
Run 100: Complete all unlocks
Run 200+: Mastery, speedruns, challenges
```

---

← [[00_Home|Home]] | [[42_Unlocks|Unlocks Detail →]]
