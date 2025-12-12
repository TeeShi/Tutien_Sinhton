# ⚔️ Core Gameplay Loop

← [[00_Home|Quay lại Home]] | [[01_Vision|← Vision]]

---

## Tổng Quan

### The 30-Minute Tribulation
Mỗi run trong Tu Tiên Sinh Tồn là một **Tiểu Thiên Kiếp** (Small Heavenly Tribulation) kéo dài 30 phút. Mục tiêu: sinh tồn đến khi Thiên Lôi (Heavenly Thunder) giáng xuống.

```
┌─────────────────────────────────────────────────────────────────┐
│                    MỘT LƯỢT CHƠI (RUN)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   0:00 ──────────── 15:00 ──────────── 30:00                   │
│    │                  │                  │                      │
│    ▼                  ▼                  ▼                      │
│  START              GIỮA              THIÊN LÔI                 │
│  Yếu ớt            Mạnh dần          Bất bại                   │
│  Chạy trốn         Cân bằng          Thống trị                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Core Loop Diagram

```
                    ┌─────────────────┐
                    │   BẮT ĐẦU RUN   │
                    └────────┬────────┘
                             │
                             ▼
            ┌────────────────────────────────┐
            │                                │
            │   ┌────────────────────────┐   │
            │   │    SURVIVAL LOOP       │   │
            │   │                        │   │
            │   │  1. Di chuyển (INPUT)  │   │
            │   │  2. Công Pháp tự kích  │   │
            │   │  3. Yêu Ma xuất hiện   │   │
            │   │  4. Tiêu diệt Yêu Ma   │   │
            │   │  5. Thu Linh Khí (XP)  │   │
            │   │                        │   │
            │   └───────────┬────────────┘   │
            │               │                │
            │               ▼                │
            │      ┌────────────────┐        │
            │      │  ĐỦ LINH KHÍ?  │        │
            │      └───────┬────────┘        │
            │         YES  │  NO             │
            │              │   └─────────────┤
            │              ▼                 │
            │      ┌────────────────┐        │
            │      │   ĐỘT PHÁ!    │        │
            │      │  Chọn 1/3     │        │
            │      │  Công Pháp/   │        │
            │      │  Đan Dược     │        │
            │      └───────┬───────┘        │
            │              │                 │
            └──────────────┴─────────────────┘
                           │
                           ▼
                  ┌────────────────┐
                  │  30 PHÚT ĐẾN?  │
                  └───────┬────────┘
                     YES  │  NO
                          │   └──────► Tiếp tục loop
                          ▼
                  ┌────────────────┐
                  │  THIÊN LÔI!    │
                  │  (Instant kill)│
                  └───────┬────────┘
                          │
                          ▼
                  ┌────────────────┐
                  │  KẾT THÚC RUN  │
                  │  Thu Linh Thạch│
                  └───────┬────────┘
                          │
                          ▼
                  ┌────────────────┐
                  │ META PROGRESS  │
                  │ Mua PowerUps   │
                  │ Unlock content │
                  └───────┬────────┘
                          │
                          ▼
                  ┌────────────────┐
                  │   RUN MỚI      │
                  └────────────────┘
```

---

## Phases of a Run

### Phase 1: Khởi Đầu (0:00 - 5:00)

| Aspect | Description |
|--------|-------------|
| **Feel** | Yếu ớt, sợ hãi, chạy trốn |
| **Enemies** | Yêu Trùng cơ bản, ít |
| **Player** | 1 Công Pháp, level thấp |
| **Goal** | Thu Linh Khí, sống sót |
| **Level ups** | Cứ 10-15 giây |

**Narrative:** *Tu Sĩ vừa bước vào Bí Cảnh, Yêu Khí bắt đầu tụ lại...*

### Phase 2: Phát Triển (5:00 - 15:00)

| Aspect | Description |
|--------|-------------|
| **Feel** | Đang mạnh lên, cân bằng |
| **Enemies** | Nhiều loại, density tăng |
| **Player** | 3-4 Công Pháp, đang build |
| **Goal** | Tập trung build, evolution |
| **Level ups** | Cứ 20-30 giây |

**Narrative:** *Tu Vi tăng dần, nhưng Yêu Ma cũng đang tập trung về phía tu sĩ...*

### Phase 3: Thống Trị (15:00 - 25:00)

| Aspect | Description |
|--------|-------------|
| **Feel** | MẠNH, thỏa mãn, power fantasy |
| **Enemies** | Maximum density |
| **Player** | Full build, Thần Thông |
| **Goal** | Clear màn hình, tìm secrets |
| **Level ups** | Cứ 30-45 giây |

**Narrative:** *Thần Thông đại thành! Yêu Ma chỉ là đám kiến dưới chân!*

### Phase 4: Cực Điểm (25:00 - 30:00)

| Aspect | Description |
|--------|-------------|
| **Feel** | God mode, bất bại |
| **Enemies** | Overwhelming but irrelevant |
| **Player** | Maxed out |
| **Goal** | Survive until Thiên Lôi |
| **Tension** | Countdown đến kết thúc |

**Narrative:** *Thiên Địa rung chuyển, Thiên Lôi sắp giáng xuống!*

---

## Micro-Loop: Level Up Choice

```
┌─────────────────────────────────────────────────────────────────┐
│                    LEVEL UP SCREEN                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│    ┌───────────┐    ┌───────────┐    ┌───────────┐             │
│    │  OPTION 1 │    │  OPTION 2 │    │  OPTION 3 │             │
│    │           │    │           │    │           │             │
│    │  [ICON]   │    │  [ICON]   │    │  [ICON]   │             │
│    │           │    │           │    │           │             │
│    │ Phi Kiếm  │    │ Hỏa Cầu   │    │ Lv Up     │             │
│    │   NEW     │    │   NEW     │    │ Phi Kiếm  │             │
│    │           │    │           │    │  Lv 2→3   │             │
│    └───────────┘    └───────────┘    └───────────┘             │
│                                                                 │
│    [REROLL: 2 left]              [SKIP: 1 left]                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Option Types

| Type | Description | Priority |
|------|-------------|----------|
| **New Công Pháp** | Thêm weapon mới (nếu < 6) | Medium |
| **Upgrade Công Pháp** | Nâng cấp weapon có | High |
| **New Đan Dược** | Thêm passive mới (nếu < 6) | Medium |
| **Upgrade Đan Dược** | Nâng cấp passive có | Low-Medium |

### Player Actions

| Action | Cost | Effect |
|--------|------|--------|
| **Chọn** | Free | Nhận option đó |
| **Reroll** | 1 Reroll | 3 options mới |
| **Skip** | 1 Skip | Bỏ qua lần này |
| **Banish** | 1 Banish | Xóa option khỏi pool vĩnh viễn (run này) |

---

## Boss Schedule

| Time | Boss | Reward |
|------|------|--------|
| 10:00 | Yêu Vương Tier 1 | Treasure Chest (evolution trigger) |
| 12:00 | Yêu Vương Tier 1 | Treasure Chest |
| 15:00 | Yêu Vương Tier 2 | Treasure Chest |
| 20:00 | Yêu Vương Tier 2 | Treasure Chest |
| 25:00 | Yêu Vương Tier 3 | Treasure Chest |
| 30:00 | **THIÊN LÔI** | Run ends |

---

## Win/Lose Conditions

### Victory ✅
- Survive until 30:00
- Thiên Lôi descends
- Run ends with maximum rewards

### Defeat ❌
- HP reaches 0 before 30:00
- Revival items can save once

### Either Way
- Keep all Linh Thạch (gold) collected
- Progress on achievements
- Unlock conditions checked
- Stats recorded

> **Design Note:** NO punishment for losing. Every run = progress.

---

## Session Flow

```
MENU → CHỌN TU SĨ → CHỌN BÍ CẢNH → [CHỌN THIÊN MỆNH] → 
RUN (30 min) → RESULTS → POWERUP SHOP → MENU
```

### Time Investment

| Session Type | Duration | Content |
|--------------|----------|---------|
| Quick | 35-40 min | 1 run + shop |
| Normal | 1-1.5 hours | 2-3 runs |
| Deep | 2+ hours | Multiple runs + experimenting |

---

← [[01_Vision|Vision]] | [[00_Home|Home]] | [[03_Controls|Controls →]]
