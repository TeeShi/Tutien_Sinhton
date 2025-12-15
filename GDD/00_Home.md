# 🏠 Tu Tiên Sinh Tồn - Game Design Document

> **Tên game:** Tu Tiên Sinh Tồn (Cultivation Survivors)
> **Thể loại:** Roguelike Auto-Battler / Bullet Heaven
> **Engine:** Godot 4
> **Platform:** PC (Steam) → Mobile
> **Triết lý:** Tôn trọng người chơi, không P2W

---

## 📚 Wiki Navigation

### 🎯 Core Documents
| Trang | Mô tả |
|-------|-------|
| [[00_Home]] | Trang chủ (đang xem) |
| [[01_Vision]] | Tầm nhìn & mục tiêu game |
| [[02_Core_Loop]] | Vòng lặp gameplay chính |
| [[03_Controls]] | Điều khiển |

### 👤 Player Systems
| Trang | Mô tả |
|-------|-------|
| [[10_Tu_Si]] | Hệ thống Tu Sĩ (Characters) |
| [[11_Linh_Can]] | 5 loại Linh Căn |
| [[12_Stats]] | Các chỉ số nhân vật |

### ⚔️ Combat Systems  
| Trang | Mô tả |
|-------|-------|
| [[20_Cong_Phap]] | Hệ thống Công Pháp (Weapons) |
| [[21_Dan_Duoc]] | Hệ thống Đan Dược (Passives) |
| [[22_Than_Thong]] | Hệ thống Thần Thông (Evolutions) |
| [[23_Damage]] | Công thức sát thương |

### 👹 Enemies
| Trang | Mô tả |
|-------|-------|
| [[30_Yeu_Trung]] | Yêu Trùng (Swarm enemies) |
| [[31_Yeu_Thu]] | Yêu Thú (Elite enemies) |
| [[32_Yeu_Vuong]] | Yêu Vương (Bosses) |
| [[33_Thien_Loi]] | Thiên Lôi (Death) |

### 📈 Progression
| Trang | Mô tả |
|-------|-------|
| [[40_Linh_Khi]] | XP & Level Up |
| [[41_Meta]] | Meta Progression |
| [[42_Unlocks]] | Mở khóa content |
| [[43_Thien_Menh]] | Hệ thống Thiên Mệnh (Arcanas) |

### 🗺️ World
| Trang | Mô tả |
|-------|-------|
| [[50_Bi_Canh]] | Các Bí Cảnh (Stages) |
| [[51_Lore]] | Thế giới quan |

### 🎨 Art & Audio
| Trang | Mô tả |
|-------|-------|
| [[50_Audio]] | 🎵 Audio Design & Workflow (Template) |
| [[60_Art_Style]] | Phong cách nghệ thuật |
| [[62_UI]] | Giao diện người dùng |

### 💰 Business
| Trang | Mô tả |
|-------|-------|
| [[70_Monetization]] | Mô hình kinh doanh |
| [[71_Roadmap]] | Lộ trình phát triển |

---

## 🎮 Game Overview

### Elevator Pitch
> *"Vampire Survivors gặp Tu Tiên - Sinh tồn qua Thiên Kiếp, tu luyện thành Tiên!"*

### Mô tả ngắn
**Tu Tiên Sinh Tồn** là game roguelike auto-battler nơi người chơi điều khiển một Tu Sĩ, sinh tồn qua 30 phút Thiên Kiếp đầy Yêu Ma. Thu thập Linh Khí, học Công Pháp mới, uống Đan Dược, và đột phá thành Thần Thông để trở thành bất khả chiến bại!

### Core Fantasy
```
Từ Tu Sĩ yếu đuối → Thành Tiên Nhân bất bại trong 30 phút
```

### Unique Selling Points
1. **Theme Tu Tiên độc đáo** - Khác biệt với hàng trăm VS clones
2. **Ngũ Hành System** - 5 nguyên tố tương sinh tương khắc
3. **Đột Phá mechanics** - Evolution = Breakthrough cultivation
4. **Không P2W** - Trả 1 lần, chơi mãi mãi
5. **Made in Vietnam** - Phù hợp văn hóa địa phương

---

## 📊 Quick Reference

### Số liệu chính
| Metric | Value |
|--------|-------|
| Thời gian 1 run | 30 phút |
| Số Công Pháp (weapons) | 15+ |
| Số Đan Dược (passives) | 12+ |
| Số Thần Thông (evolutions) | 12+ |
| Số Tu Sĩ (characters) | 10+ |
| Số Bí Cảnh (stages) | 5+ |
| Số Thiên Mệnh (arcanas) | 10+ |

### Development Status

| Phase | Status | Target |
|-------|--------|--------|
| Pre-production | 🟡 In Progress | Week 1-2 |
| Prototype | ⚪ Not Started | Week 3-4 |
| Alpha | ⚪ Not Started | Month 2 |
| Beta | ⚪ Not Started | Month 3 |
| Release | ⚪ Not Started | Month 4 |

---

## 🔗 Quick Links

- [[02_Core_Loop|Bắt đầu với Core Loop →]]
- [[20_Cong_Phap|Xem danh sách Công Pháp →]]
- [[10_Tu_Si|Xem danh sách Tu Sĩ →]]
- [[71_Roadmap|Xem Roadmap →]]

---

*Last Updated: 12/12/2024*
*Version: 0.1.0*
